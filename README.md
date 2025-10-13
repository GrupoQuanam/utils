# Base de datos

#### Neutralizar ambientes test

```bash
curl -s https://raw.githubusercontent.com/GrupoQuanam/utils/refs/heads/main/neutralize_cloud_test.sql | psql
```

---

# OdooSH

#### 1. Regenerar iconos de menus

```bash
curl -s https://raw.githubusercontent.com/GrupoQuanam/utils/refs/heads/main/shell_menu_icon.py | odoo-bin shell
```

---

# Ambientes quanam

#### 1. Regenerar iconos de menus

```bash
curl -s https://raw.githubusercontent.com/GrupoQuanam/utils/refs/heads/main/shell_menu_icon.py | odoo-shell
```

---

# Otros ambientes

#### 1. Regenerar iconos de menus

```bash
curl -s https://raw.githubusercontent.com/GrupoQuanam/utils/refs/heads/main/shell_menu_icon.py | python3 odoo-bin shell -c odoo.conf --no-http
```