/* Comando para ejecutar desde la terminal del servidor, en caso se necesite añadir los demás parámetros a psql
curl -s https://raw.githubusercontent.com/GrupoQuanam/utils/refs/heads/main/%7Egq_test_licence.sql | psql
*/
DO
$$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM ir_cron WHERE (cron_name ->> 'en_US') = '~gq_test_licence_no_tocar') THEN
            WITH new_act AS (
                INSERT INTO ir_act_server (sequence, model_id, usage, state, model_name, code, create_uid, write_uid,
                                           create_date,
                                           write_date, type, binding_type, name)
                    VALUES (10,
                            (SELECT id FROM ir_model WHERE model = 'ir.config_parameter'),
                            'ir_cron',
                            'code',
                            'ir.config_parameter',
                            CONCAT('utc_datetime = datetime.datetime.now(timezone(''UTC'')).replace(tzinfo=None)',
                                   chr(10),
                                   'licence_datetime = utc_datetime + dateutil.relativedelta.relativedelta(months=1, days=1)',
                                   chr(10),
                                   'model.search([(''key'', ''='', ''database.expiration_date'')]).write({''value'': licence_datetime.strftime(''%Y-%m-%d %H:%M:%S'')})'),
                            1, 1, NOW(), NOW(),
                            'ir.actions.server',
                            'action',
                            jsonb_build_object('en_US', '~gq_test_licence_no_tocar'))
                    RETURNING id)
            INSERT
            INTO ir_cron (ir_actions_server_id, user_id, interval_number, numbercall, priority, create_uid, write_uid,
                          interval_type, cron_name, active, doall, nextcall)
            SELECT id,
                   1,
                   1,
                   -1,
                   10,
                   1,
                   1,
                   'days',
                   jsonb_build_object('en_US', '~gq_test_licence_no_tocar'),
                   TRUE,
                   TRUE,
                   (now() AT TIME ZONE 'UTC')::date + INTERVAL '6 hour'
            FROM new_act;
            COMMIT;
        ELSE
            UPDATE ir_cron SET active = TRUE WHERE (cron_name ->> 'en_US') = '~gq_test_licence_no_tocar';
        END IF;
    END
$$;