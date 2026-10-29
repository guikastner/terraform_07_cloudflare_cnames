# ☁️ Cloudflare CNAMEs & Redirects — edição OpenTofu

> *"Eu só queria apontar um subdomínio."* — Toda pessoa, 4 horas antes de entender DNS.

Este projeto pega um JSON humilde e transforma em **CNAMEs** e **redirecionamentos** de verdade na zona `kastner.com.br` da Cloudflare. Você edita o JSON, roda `tofu apply`, e a Cloudflare obedece. Apagou do JSON? Some da Cloudflare. Sem cliques no painel, sem "quem criou esse registro em 2019?".

Diferente do primo `TERRAFORM_02_CLOUDFLARE_TUNNEL_CNAMES`, aqui não tem túnel: os CNAMEs apontam para qualquer lugar que aceite ser apontado.

## 🗺️ O mapa da mina

![Fluxo: dns.json → tofu apply → Cloudflare](https://kroki.io/excalidraw/svg/eNrtmstu4zYUhvd-CsHdtGgiiLKu2WXSKZpFB4NJgS6aLmiRktnQpCDJk3gGAaabbgeYVRftots-QffzJnmBvkJJWbYuiSy6TUawqwSJLfLwosOfn0gevR1p42wZ4_GJNsY3AaQEJfB6fCSSX-MkJZyJHFNepnyRBLnddEEo0uNlboUpnmOWpSLjh5GmvRV_2pggaZfgIIMsovjYlKZa2dImp0i_kY0Yq-9L8R1YxcU1QdkszywSZphEs0yagCJlVc-JVlymWcKv8BmnPJEtfQaw_C3amcLgKkr4gqHSIAxx4PuFQUgovciWeYXjGQxmi2RddlXx9-sOVRM3JVIu_FfYi2aiGcOp9AxYJfEYBiTLb3B9P7I38TnK3fdj0YcEzvG59CBbULqpjKGistzFG19O5NVt0RuMUdm3cvxALeEFZ_k4FmYk_UqMYZaXDCFNceEq2eLzcnDLvixiBFfmRb2UsKuaBeXBVVnfqOhfVRoZvsmOJw1VyMQ2QdiubndJwrX1x9FElkCWxjARt75HuihTCx1M1HQw-UQ6KAZbDrJwCWKp_lPK2SX7nGspjhKM-CVDUAtgCr8ofMUTEhEG6Xe7FAo5yy7IG1yRkEz6Gs4JXZa9lR05pSSSjhkH4u5wMt74JyMChZvcOUGIlnpJsbhTWT3wVkmBqB6KpKQxOtLsmw2wdNN-aCqUlLQUKDnpC5PQRl4YHhImLbXpYfWNSXs7JuuKcA29UxO2MXCyKgRbTQh2L5zMeLjQYBzTpYAe1OYf_4gEm9oAud16b8noKJDRqc6De2C07oHReCQwTs3QnE4PCYyO2nxw-gajux2MNUE4tt4piYGLdS66ajpwe-Hi2YvTb5-nl2xKeaTd_fJBi0g2W0x1wlvQ2Flgb-no7UpH0-7Go_lo2-vADw5qe-2pTQuvbzz6O-DRdM17-2tr2F9v56OvJgS_Fz6easA3dUM3dSCWgnHCbwhGR9r5S7FfxppsjSSEzVpXkruW31t6AkMBn77TEz6RMQ0Pa9u9PpDomjZru_4ACsB2gtZF4Q0rzJ0JCoCiFkAvDH2FEZE00F4tKL5kYl-dLxwRTjPC2taZSoX2jJYwSfj1MWiGcfLk6ol97SjKbywowL2DqP_zXKhz0nyAk4phHGB-0rkRc1JG-7TifzF04jP_WLlgnbf20iZ3tDERnodJdiplNMOw7izMUDWjJjYK0-yMz-ckEzfwUvaoThdZ6zPCEGFRs856cjv7u4JTjpgrFbE7fpP-wNWdht5NVfxbvm3Y7uHjXzFCBfoJUdGPf7YwvsypgBw4Twty6_FAbnWA3G7EFLpAfuzaA8q3oFwx1ASsvUG5GPE9gnlHCM22Td2qCN5wmochE3tN-wHmbTBXDKOBfuJoQUJgC80rWfuJc2cXnG8W6e0494aF-TaaK8bHgLM3NPf2aWXu7gRzc2I1V-YDzLthrhj7A-4A80eGudcBc6966jgBxnDI8l9YrhjMA95wyPIEKO8IUXquXz1kMb17KHeA7hiVHzBwfTvXFWOWoJ-g5ZdagqOkDe313D2jey540-h4l9OrvsPWXKhPrIluVtVuN9Q-UVV7aHiBYRy82k3FUKNp9PMKE-ULFFLh5hPt7t1v_OpIC2Y4xHfvftfufv3577_et73KpFqwGmaynnSOmOBfzJFR_oQawzi-yIQfiwf2-DXB188efJUoXMfChTwIKu5s9YiRE06qFOfP_dvR7T86jHqp)

- **`cnames`** → um `CNAME` por entrada. Simples, honesto, sem drama.
- **`redirects`** → duas peças por entrada:
  1. um registro `A` **proxied** apontando para `192.0.2.1`, um IP de documentação que não leva a lugar nenhum (CNAME não aceita IP, e o registro só existe para o tráfego passar pela Cloudflare);
  2. uma regra no ruleset `http_request_dynamic_redirect` da zona, que responde com o redirect antes de alguém notar que o IP é de mentirinha.

## 🚶 O que acontece quando alguém acessa um redirect

![Visitante → Cloudflare Edge → 301](https://kroki.io/excalidraw/svg/eNrtms9v2zYUx-_-KzTvsgGNJpGSbPXWZtlWoBiGptgOyw60RFuEKVKQ6MZeEaCn3bvTDht6HHbff7D_JH9B_4SRMvUzcaRgThxndpDYfnx8pB6_7yNCzNuBMRSrBA-fGkO8DBAlYYrOh0-k-Q1OM8KZbAHqa8YXaZD7TRaEhmayyr0wxTFmIpMNPw4M4638NYYkVH4pDgRiM4qPgK18jWqosknbl2oUa_15JT_bxZdzEopIGcbaEGEyi4SyWNqyjvPU0F8zkfI5PuaUp2qkT22sfvQ4ExTMZylfsLBymE5x4PvaYUooPRWrPOAwQkG0SIu-68A_6AmBurHskXGZQO0vh5lFDGcqNfbaxBMUELGqz17NJnkR5vn7Sc8hRTF-oVLIFpSWwViog-U5LnMJ1bcLPRuMVTegh6tWsGn4lrN8JQs_kn0pl1HkfaeIZlgnS415Uq1vNZtFEqK1u45ACZs3PCgP5lW8gZ5hXR0CL8URAC1hKOsmTTgj0-1SheOa25GFSBHLEpTKa98jaVTWQgqgpxTAPUlBL7daZpmUjx_-fG98TzIiaSDwGUNJYs5RJhhOzYDH5iTVGeMpmRGG6OvbdpxyJk7JzzhXS2X6CsWErqpZqwk9o2SmMjQM5FXiIoBMlCASjGVrTMKQVsrJsLziPLy3NgUyPJKmtLVOyu2bkl4mcK-rihozYQ9mQqteIFYLmsC7Ak1nS9BEbjieTh8VNGHPSoE7h6ZzMzSbooCelFqXLrwSrQds5mJweorB2Qk2jylfhFMq02ychDOJv8t3v8srwUbEM2EIHJ-xVzgkihjGqwXFn1y--2MDSP9DqP1Fq9sDrZ53034UOHe2H52AKZhMHhVa3Z7V5O4crd7NaG2K4uqG9KosDhvSFlm9nlrwdkJWaNnG5S-_GiHOBGH8jJl4ieKEYrWr3IDQPn32l5Wj225DIezchvpbQiX2cYAf1y501LM8RjtH5fgWu1DoArNzE3pAZQuV455aGO8ElbYPTMsEpn3GPmMLFiDjn7-MIEIxCrnx8cNvf3--gZe9O-4ZNFGa8vMj4LfqIjc3nmnV9xCj9oNOq10W_-eaaPISXMNLv2eN-PdaIwkn1TNxQ__VSyff87d1Coq2Iktl66B0kZlHqXimZBRh1EwWZmG9oSE2ijJxzOOYCHkB36kZNSmjoj4nLCRs1o7ZNG-8B0Cr4_EtgKZX3zA7Zkvu8r4wtuovp6V-YPW8KTi-a7mjR39TKDZXXYIv_O75pvD1yWvji-UG8Dca63D37hbuztbgDu0OuLveAe5bgzvseY4F7QPc7wDuHWdz7sgxxzfCfWSZB5x34Lzn-RzczfncSx4goeZ1PdBbzfuJdNiBdAfWkF4-4Cs0fkePNrYu7xBlEX4ASO95ygbhA0d60ebvE9E7Dg4dGxTAzrXu-m2iQ9cEB6LfTPSeR4dwN0eHjCd4A81rTQ-c5IO81IYoSU6FzIUGz_ANwefPr_0PL_XKx5ZLTEJ9ZetaUaWilIZzfl0MLv4FxFi5ww==)

O `192.0.2.1` passa a vida inteira sem receber uma única requisição. É o estagiário que só existe no organograma.

## 🔁 O ciclo da vida (de um registro)

![Ciclo de plan/apply](https://kroki.io/mermaid/svg/eNqNkL1KA1EQhfs8xWErRdwUdotEJIIQ8YcQLOzGvbPxymbnOvduiIilb2FnJ1j5CHkTn8TJTxGNhbe5MN_MOWcm8kPLTcknnsZKkw7sUZlEcdp6UMS1lPP3ZTmQJl_6QE3CYIFcE_P7KM0WHS3oZeBmJFW7RfsL2q-ldVVNyktuZvu93qAAOWuThpBRCFmBJ2RJ7M_uUgqx6HbzPM_wvDE0KpDMBqGmVZKRFfsFBLYZeOZjYtD842gJ-_urkYYcwXGMxkJY8PWsYdMtcGVyBQ5M2zI57CjH4JVQtY2T3T_8TaZ-3AxQqiccI6jMPDvsYcjOK5cJw7bmH2kq9ubz9fry6xiBxutL_McwyoRRygQ-RlmCC7HdZcoKwzesAuWxHUQlYv6p1fxNYn54q93eOalnnIktZ8IqU8o734-rpxg=)

## 🧰 Requisitos
- OpenTofu `>= 1.6` (sim, **OpenTofu**. `terraform` aqui é palavrão leve.)
- API token Cloudflare com, na zona:
  - **DNS:Edit**
  - **Single Redirect:Edit** (alguns painéis chamam de *Dynamic Redirect*, porque nomear coisas é difícil)

## ⚙️ Configuração
1. Segredos no lugar certo:
   ```bash
   cp terraform.tfvars.example terraform.tfvars   # api_token, zone_id, zone_name
   ```
2. O JSON (que **não** vai ao git):
   ```bash
   cp dns.example.json dns.json
   ```
   ```json
   {
     "cnames": {
       "blog": { "target": "meusite.github.io", "proxied": false, "ttl": 3600 }
     },
     "redirects": {
       "app": { "to": "https://destino.example.com", "status_code": 301 }
     }
   }
   ```

| Campo | Seção | Obrigatório | Padrão | Comentário sincero |
|---|---|---|---|---|
| chave (`blog`, `app`, `@` = raiz) | ambas | sim | — | o subdomínio em si |
| `target` | cnames | sim | — | para onde o CNAME aponta |
| `proxied` | cnames | não | `var.proxied` | nuvem laranja 🟠 ou cinza ☁️ |
| `ttl` | cnames | não | `1` (auto) | ignorado se proxied; a Cloudflare manda |
| `to` | redirects | sim | — | URL absoluta `http(s)://...` |
| `status_code` | redirects | não | `301` | 301/302/307/308; o resto é validado e barrado |
| `preserve_path` | redirects | não | `true` | `/x` vira `to/x` |
| `preserve_query` | redirects | não | `true` | `?utm=...` sobrevive à viagem |
| `comment` | ambas | não | `Managed by OpenTofu` | para o você do futuro |

Regras da casa:
- Um subdomínio não pode estar em `cnames` **e** em `redirects` ao mesmo tempo. O `plan` reclama antes de você fazer besteira.
- Não declare subdomínios que já são do projeto 02 (tunnel). Dois states brigando pelo mesmo registro não terminam bem.

### 🥊 "Error: ruleset already exists"
A Cloudflare só permite **um** ruleset de redirect por zona. Se você já criou Single Redirects pelo painel, o primeiro apply vai reclamar. Importe o ruleset existente; as regras dele serão substituídas pelas do JSON, então anote o que importa antes:
```bash
tofu import 'cloudflare_ruleset.redirects[0]' zone/<zone_id>/<ruleset_id>
```

## 🚀 Execução
```bash
tofu init
tofu plan      # leia. sério, leia.
tofu apply
tofu output
```

## 🔐 O que vai e o que não vai ao git

| Vai 👍 | Não vai 🙅 |
|---|---|
| `*.tf`, `.terraform.lock.hcl` | `terraform.tfvars` (tem o token!) |
| `dns.example.json`, `terraform.tfvars.example` | `dns.json` |
| `docs/diagrams/*` | `*.tfstate*`, `.terraform/` |

## 🎨 Diagramas
Os diagramas são renderizados pelo [Kroki](https://kroki.io): os dois primeiros em **Excalidraw** e o ciclo em Mermaid. As fontes ficam em `docs/diagrams/`. Para alterar um diagrama, edite o `build.py` (Excalidraw) ou o `.mmd`, rode o script abaixo e cole as URLs novas aqui:
```bash
python3 docs/diagrams/build.py
```
Os arquivos `.excalidraw` também abrem direto em [excalidraw.com](https://excalidraw.com).

## 🧑‍💻 Fluxo de trabalho (Git)
- `main` é o branch estável; commits no padrão [Conventional Commits](https://www.conventionalcommits.org/pt-br/) (`feat: adiciona redirect do app`).
- `tofu fmt -recursive` e `tofu validate` antes de commitar. Se quiser hooks: `pipx install pre-commit && pre-commit install`.
- O CI (`.github/workflows/ci.yml`) roda `fmt` + `validate` em todo push para `main` e em PRs.
