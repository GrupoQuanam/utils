import os

files = env['ir.attachment'].sudo().with_context(prefetch_fields=False).search(
    [('id', '>', 0), ('type', '=', 'binary')], order='id')
total, i = len(files), 0
files._read(['name'])
for file in files.exists():
    i += 1
    position = f'{str(i).zfill(len(str(total)))} / {total}'
    file_name = file.name
    full_path = file._full_path(file.store_fname)
    if os.path.exists(full_path):
        print(position, file.id, 'Existe', file_name)
    else:
        try:
            file.unlink()
            env.cr.commit()
        except:
            pass
        print(position, file.id, 'No existe', file_name)
