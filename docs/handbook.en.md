# Handbook (EN) – Alby Hub Home Assistant Add-on & Integration

## Target Version and Compatibility

- Minimum supported Home Assistant version (2026.x): **2026.1**
- Applies to the add-on and planned HACS integration in the MVP.

## Add-on vs Integration (quick overview)

- **Add-on (`ha-btc-alby-hub-addon`)**: Provides the Alby Hub service (local add-on runtime or cloud bridge via NWC). This requires Home Assistant with Supervisor/add-on support.
- **Integration (`ha-btc-alby-hub-integration`)**: Connects Alby Hub to Home Assistant (entities, services, automations, dashboard).
- Recommendation: On HA OS/Supervised, usually use **add-on + integration** together; on HA Container, primarily use the **integration** with an external hub.

<a id="support-matrix-en"></a>
## Support Matrix (MVP)

| Installation type | Support status | Limitations |
|---|---|---|
| Home Assistant OS | Supported | Full Supervisor/add-on flow is recommended |
| Home Assistant Supervised | Supported | Add-on behavior depends on a clean Supervisor setup on the host |
| Home Assistant Container | Supported (limited) | No native add-on store/Supervisor; primarily use the HACS integration and external services |

<a id="setup-tests-en"></a>
## Setup Tests in the Wizard

### Required tests
- Connectivity check (Hub/NWC reachable)
- Scope check (required permissions granted)

### Optional test
- 1-sat live test payment (shown as optional, never mandatory)
- Always shown with a short risk/cost explanation

## Behavior on Test Failures

- MVP rule: **Continue with warning** is allowed.
- Optional-step failures do not block setup completion.
- Required-test failures are surfaced clearly; users can still complete setup with warning in MVP.

## Setup UX Texts

- Inline explanations in short mode (1–2 sentences)
- A “Learn more” link per step pointing to the relevant handbook section

## MVP Languages

- Required: **DE + EN** for full config/options flows
- Additional languages (e.g., FR, ES) are planned for later releases

## HACS Release Policy

- Start at version **0.0.0**
- Version format: **x.y.z**
  - `z` = pre-release
  - `y` = release
  - `x` = major release
- Every release includes release notes and a compatibility note
