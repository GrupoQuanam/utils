import os


def dividir_en_bloques(array, tamano_bloque):
    return [array[x:x + tamano_bloque] for x in range(0, len(array), tamano_bloque)]


files = env['ir.attachment'].sudo().with_context(prefetch_fields=False).search(
    [('id', '>', 0), ('type', '=', 'binary')], order='id')
to_delete = env['ir.attachment']
for file in files.exists():
    full_path = file._full_path(file.store_fname)
    if not os.path.exists(full_path):
        to_delete += file

if to_delete:
    lots = dividir_en_bloques(to_delete.ids, 100)
    total, i = len(lots), 0
    for lot in lots:
        i += 1
        position = f'{str(i).zfill(len(str(total)))} / {total} | {lot[0]}...{lot[-1]}'
        try:
            env['ir.attachment'].sudo().with_context(prefetch_fields=False).browse(lot).unlink()
            env.cr.commit()
        except:
            env.cr.rollback()
        print(position)
