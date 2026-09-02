<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';

import KanbanEmbedSessionAPI from 'dashboard/api/kanbanEmbedSession';
import { useAlert } from 'dashboard/composables';

const MESSAGE_READY = 'ts-products.crm.ready.v1';
const MESSAGE_SESSION = 'ts-products.crm.embed.v1';
const MESSAGE_OPEN_CONVERSATION = 'ts-products.crm.open-conversation.v1';
const MESSAGE_OPEN_CONTACT = 'ts-products.crm.open-contact.v1';

const route = useRoute();
const router = useRouter();
const { t } = useI18n();
const frame = ref(null);
const appUrl = ref('');
const appOrigin = ref('');
const initialTicket = ref('');
const isLoading = ref(true);
const hasError = ref(false);

const frameTitle = computed(() =>
  t('KANBAN.FRAME_TITLE', { accountId: route.params.accountId })
);

async function prepareFrame() {
  isLoading.value = true;
  hasError.value = false;
  try {
    const { data } = await KanbanEmbedSessionAPI.create();
    appUrl.value = data.app_url;
    appOrigin.value = new URL(data.app_origin).origin;
    initialTicket.value = data.ticket;
  } catch {
    hasError.value = true;
    isLoading.value = false;
  }
}

async function sendSessionTicket() {
  try {
    let ticket = initialTicket.value;
    if (ticket === '') {
      const { data } = await KanbanEmbedSessionAPI.create();
      if (new URL(data.app_origin).origin !== appOrigin.value)
        throw new Error('Origin changed');
      ticket = data.ticket;
    }
    initialTicket.value = '';
    frame.value?.contentWindow?.postMessage(
      { type: MESSAGE_SESSION, ticket },
      appOrigin.value
    );
    isLoading.value = false;
  } catch {
    hasError.value = true;
    isLoading.value = false;
    useAlert(t('KANBAN.SECURE_SESSION_ERROR'));
  }
}

async function handleFrameMessage(event) {
  if (
    event.origin !== appOrigin.value ||
    event.source !== frame.value?.contentWindow ||
    typeof event.data !== 'object' ||
    event.data === null
  ) {
    return;
  }

  if (event.data.type === MESSAGE_READY) {
    await sendSessionTicket();
    return;
  }

  if (
    event.data.type === MESSAGE_OPEN_CONVERSATION &&
    typeof event.data.conversationId === 'string'
  ) {
    await router.push({
      name: 'inbox_conversation',
      params: {
        accountId: route.params.accountId,
        conversation_id: event.data.conversationId,
      },
    });
    return;
  }

  if (
    event.data.type === MESSAGE_OPEN_CONTACT &&
    typeof event.data.contactId === 'string'
  ) {
    await router.push({
      name: 'contacts_edit',
      params: {
        accountId: route.params.accountId,
        contactId: event.data.contactId,
      },
    });
  }
}

onMounted(async () => {
  window.addEventListener('message', handleFrameMessage);
  await prepareFrame();
});

onBeforeUnmount(() => {
  window.removeEventListener('message', handleFrameMessage);
});
</script>

<template>
  <section class="relative flex flex-1 min-w-0 min-h-0 bg-n-background">
    <div
      v-if="isLoading"
      class="absolute inset-0 z-10 flex flex-col items-center justify-center gap-3 bg-n-background text-n-slate-11"
    >
      <span
        class="size-6 i-lucide-loader-circle animate-spin"
        aria-hidden="true"
      />
      <p class="text-sm">{{ $t('KANBAN.CONNECTING') }}</p>
    </div>
    <div
      v-if="hasError"
      class="flex flex-1 flex-col items-center justify-center gap-3 px-6 text-center"
      role="alert"
    >
      <span
        class="size-8 i-lucide-panels-top-left text-n-slate-9"
        aria-hidden="true"
      />
      <div>
        <h1 class="text-base font-medium text-n-slate-12">
          {{ $t('KANBAN.ERROR_TITLE') }}
        </h1>
        <p class="mt-1 text-sm text-n-slate-10">
          {{ $t('KANBAN.ERROR_MESSAGE') }}
        </p>
      </div>
      <button
        type="button"
        class="h-9 px-3 rounded-lg bg-n-brand text-white text-sm font-medium"
        @click="prepareFrame"
      >
        {{ $t('KANBAN.RETRY') }}
      </button>
    </div>
    <iframe
      v-if="appUrl && !hasError"
      ref="frame"
      class="flex-1 w-full h-full border-0 bg-n-background"
      :src="appUrl"
      :title="frameTitle"
      sandbox="allow-same-origin allow-scripts"
    />
  </section>
</template>
