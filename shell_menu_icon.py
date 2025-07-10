# Script para regenerar los iconos de los menus cuando restauras sin filestore
menus = env['ir.ui.menu'].search([('web_icon', '!=', False)])
for menu in menus:
    try:
        menu.write({'web_icon_data': False})
        menu.write({'web_icon': menu.web_icon})
        env.cr.commit()
    except:
        env.cr.rollback()
