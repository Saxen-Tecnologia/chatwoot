/* global axios */

import ApiClient from './ApiClient';

class KanbanEmbedSessionAPI extends ApiClient {
  constructor() {
    super('kanban_embed_session', { accountScoped: true });
  }

  create() {
    return axios.post(this.url);
  }
}

export default new KanbanEmbedSessionAPI();
