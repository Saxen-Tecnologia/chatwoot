# Napkin Runbook

## Regras de curadoria

- Repriorizar em toda leitura.
- Manter somente orientações recorrentes e de alto valor.
- Limitar cada categoria aos 10 itens mais importantes.
- Exigir data e uma ação explícita em cada item.

## Execução e validação (prioridade máxima)

1. **[2026-08-26] Validar a automação Redmoto de ponta a ponta**
   Do instead: após mudanças em UAZAPI, n8n, Chatwoot, Gemini ou Supabase, confirmar ingresso `202/inbound_message`, `reply_applied`, job `completed` e exatamente um outbound correspondente na UAZAPI.

2. **[2026-08-26] Usar o ledger quando o n8n não mostrar execuções F09**
   Do instead: consultar `ai_interactions` e `outbox_messages` no Supabase, pois os workers F09 desabilitam a persistência de payloads de sucesso, erro e execução manual.

3. **[2026-08-26] Separar o fork Chatwoot do backend de orquestração**
   Do instead: tratar este repositório como o fork Chatwoot e usar o repositório irmão `../ts-products-crm` para backend, migrations, workflows n8n, prompts e runbooks operacionais.

## Segredos e serviços externos

1. **[2026-08-26] Infisical é a fonte de verdade dos segredos**
   Do instead: manter os valores no projeto Infisical e ambiente corretos, injetar com `infisical run` ou exportar diretamente para `.env.local`; nunca imprimir, documentar ou versionar valores.

2. **[2026-08-26] Manter `.env.local` local e restrito**
   Do instead: confirmar que `.env.local` está ignorado, com permissão `600`, e reconstruí-lo pelo Infisical após perda da estação.

3. **[2026-08-26] Tratar reconexão UAZAPI como troca de identidade**
   Do instead: depois de reconectar a conta gratuita, sincronizar o token no Infisical e n8n, restaurar o webhook, verificar ID/`owner` e atualizar o mapeamento Redmoto somente pela RPC auditada antes do smoke test.

4. **[2026-08-26] MCP é global; configuração e autorização são locais**
   Do instead: reutilizar instalações globais dos MCPs, mas manter endpoints, projeto, ambiente, OAuth e nomes de variáveis específicos em cada repositório.

## Guardrails do domínio

1. **[2026-08-26] Preservar isolamento entre Redmoto e TS Products**
   Do instead: resolver tenant por credenciais e mapeamentos confiáveis; manter os workflows de TS Products inativos até prompt, conhecimento e aceite próprios estarem aprovados.

2. **[2026-08-26] Distinguir silêncio por handoff de falha operacional**
   Do instead: quando não houver resposta da IA, consultar `ai_interactions`; decisão `handoff` sem resposta pública é o comportamento fail-closed esperado, mas `handoff_applied_at IS NULL` exige retomada F10 do mesmo job antes do guard de atendimento humano.

3. **[2026-08-26] Não confiar em identidade fornecida pelo webhook**
   Do instead: validar a instância UAZAPI contra `tenant_integrations`; diante de `UAZAPI_MAPPING_CONFLICT`, comprovar a identidade pelas mensagens e garantir que ela não pertence a outro tenant antes da RPC.

## Diretivas do usuário

1. **[2026-08-26] Documentar recuperação para uma máquina limpa**
   Do instead: registrar procedimentos reproduzíveis no Git sem segredos e manter o runbook `../ts-products-crm/docs/operations/recovery-runbook.md` atualizado após aprendizados operacionais.

2. **[2026-08-26] Manter o Napkin útil em todas as sessões**
   Do instead: ler e curar `.codex/napkin.md` no início, remover itens obsoletos e registrar somente gotchas e decisões recorrentes.
