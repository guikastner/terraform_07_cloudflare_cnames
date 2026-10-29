# CLAUDE.md

Projeto **OpenTofu** (não Terraform): use sempre `tofu`, nunca `terraform`. Provider `cloudflare/cloudflare ~> 4.0`.

## Git — commit e push automáticos
- Ao concluir qualquer alteração, **sempre** faça commit e push para `origin/main` sem precisar pedir confirmação.
- Mensagens em Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`), em português.
- Antes de commitar: `tofu fmt -recursive` e `tofu validate` precisam passar.
- Revise `git status` / `git diff --cached` antes de cada commit para garantir que nenhum segredo entra.

## Segredos — nunca vão ao git
- `terraform.tfvars`, `*.auto.tfvars`, `dns.json`, `*.tfstate*`, `.terraform/`, `.env`.
- Não leia nem exiba o conteúdo de `terraform.tfvars` (contém `api_token`).
- Versione apenas os exemplos: `terraform.tfvars.example`, `dns.example.json` — sempre com dados fictícios.
- `.terraform.lock.hcl` **é** versionado.

## Boas práticas OpenTofu
- Não rode `tofu apply` sem pedido explícito do usuário; `plan` e `validate` são livres.
- Variáveis tipadas, com `description` e `validation` quando fizer sentido; `sensitive = true` para credenciais.
- Mantenha `versions.tf` (versões), `variables.tf`, `main.tf`, `outputs.tf` separados.
- Mudanças de schema que afetem recursos existentes: prefira `moved {}` a destroy/create.
