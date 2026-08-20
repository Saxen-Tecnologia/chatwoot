import { frontendURL } from 'dashboard/helper/URLHelper';
import CrmWorkspace from './Index.vue';

export const routes = [
  {
    path: frontendURL('accounts/:accountId/crm'),
    name: 'crm_workspace',
    meta: { permissions: ['administrator', 'agent', 'custom_role'] },
    component: CrmWorkspace,
  },
];
