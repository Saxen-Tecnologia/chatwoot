/* global axios */
import ApiClient from './ApiClient';

class CrmSessionAPI extends ApiClient {
  constructor() {
    super('crm_session', { accountScoped: true });
  }

  create() {
    return axios.post(this.url);
  }
}

export default new CrmSessionAPI();
