""" Comando para ejecutar desde la terminal del servidor:
OdooSH:
curl -s https://raw.githubusercontent.com/GrupoQuanam/utils/refs/heads/main/shell_menu_icon.py | odoo-bin shell
Servidores configurados quanam:
curl -s https://raw.githubusercontent.com/GrupoQuanam/utils/refs/heads/main/shell_menu_icon.py | odoo-shell
Otros servidores:
curl -s https://raw.githubusercontent.com/GrupoQuanam/utils/refs/heads/main/shell_menu_icon.py | python3 odoo-bin shell -c odoo.conf --no-http
"""
# Script para regenerar los iconos de los menus cuando restauras sin filestore
menus = env['ir.ui.menu'].search([('web_icon', '!=', False)])
for menu in menus:
    try:
        menu.write({'web_icon_data': False})
        menu.write({'web_icon': menu.web_icon})
        env.cr.commit()
    except:
        env.cr.rollback()
