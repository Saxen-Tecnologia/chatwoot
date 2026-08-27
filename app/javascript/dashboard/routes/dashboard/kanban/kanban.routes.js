import { frontendURL } from 'dashboard/helper/URLHelper';

import KanbanIndex from './Index.vue';

export const routes = [
  {
    path: frontendURL('accounts/:accountId/kanban'),
    name: 'kanban_index',
    meta: {
      permissions: ['administrator', 'agent', 'custom_role'],
    },
    component: KanbanIndex,
  },
];
