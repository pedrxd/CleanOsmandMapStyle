# Flujo de trabajo (GitFlow)

```
main (trunk)
  │  ← cada push genera OSF beta automáticamente (Actions)
  │
  ├──▶ feature/xxx ──▶ PR ──▶ main     (cada PR genera OSF de prueba)
  │
  └──▶ release/v1.0 ──▶ push ──▶ GitHub Release con OSF
         release/v1.1 ──▶ push ──▶ GitHub Release con OSF
         release/v2.0 ──▶ push ──▶ GitHub Release con OSF
```

## Tipos de builds

| Rama / Evento | Versión generada | Dónde descargar |
| --- | --- | --- |
| `main` (push) | `beta-abc1234` | Actions artifacts |
| PR (pull_request) | `pr-3-abc1234` | Comentario del PR + Actions |
| `release/v1.0` (push) | `1.0` | [GitHub Releases](https://github.com/pedrxd/CleanOsmandMapStyle/releases) |

## Cómo crear una release

1. Crea una rama desde `main`: `git checkout -b release/v1.0`
2. Haz los ajustes finales (versionado, changelog)
3. Push: `git push -u origin release/v1.0`
4. La CI genera automáticamente la release en GitHub con el `.osf`

## Desarrollo local

```bash
# Generar OSF de prueba
./scripts/build-osf.sh dev

# Generar OSF con versión específica
./scripts/build-osf.sh 1.0.0
```
