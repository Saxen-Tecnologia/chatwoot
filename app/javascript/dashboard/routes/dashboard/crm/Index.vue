<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue';
import CrmSessionAPI from 'dashboard/api/crmSession';

const frame = ref(null);
const loading = ref(true);
const error = ref('');
const bootstrapRequested = ref(false);
const crmOrigin = computed(() => {
  try {
    return new URL(window.chatwootConfig?.crmOrigin || '').origin;
  } catch {
    return '';
  }
});
const embeddedUrl = computed(() =>
  crmOrigin.value ? `${crmOrigin.value.replace(/\/$/, '')}/embedded` : ''
);

const handleMessage = async event => {
  if (
    !crmOrigin.value ||
    event.origin !== crmOrigin.value ||
    event.source !== frame.value?.contentWindow ||
    event.data?.type !== 'ts-crm.ready' ||
    bootstrapRequested.value
  ) {
    return;
  }

  try {
    bootstrapRequested.value = true;
    const response = await CrmSessionAPI.create();
    frame.value?.contentWindow?.postMessage(
      { type: 'ts-crm.bootstrap', token: response.data.token },
      crmOrigin.value
    );
    loading.value = false;
  } catch {
    bootstrapRequested.value = false;
    error.value =
      'Não foi possível abrir o CRM. Atualize a página e tente novamente.';
    loading.value = false;
  }
};

onMounted(() => {
  if (!crmOrigin.value) {
    error.value = 'O endereço do CRM não está configurado.';
    loading.value = false;
    return;
  }
  window.addEventListener('message', handleMessage);
});

onBeforeUnmount(() => window.removeEventListener('message', handleMessage));
</script>

<template>
  <section
    class="relative flex size-full min-h-0 bg-slate-25 dark:bg-slate-900"
  >
    <div
      v-if="loading"
      class="absolute inset-0 z-10 flex items-center justify-center text-sm text-slate-600 dark:text-slate-300"
    >
      Abrindo CRM…
    </div>
    <div
      v-if="error"
      role="alert"
      class="m-auto max-w-lg rounded-lg border border-n-ruby-5 bg-n-ruby-1 p-6 text-center text-n-ruby-12"
    >
      {{ error }}
    </div>
    <iframe
      v-else
      ref="frame"
      :src="embeddedUrl"
      title="CRM TS Products"
      class="size-full border-0"
      referrerpolicy="no-referrer"
      sandbox="allow-forms allow-scripts allow-same-origin allow-downloads"
    />
  </section>
</template>
