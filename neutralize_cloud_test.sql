/* Comando para ejecutar desde la terminal del servidor, en caso se necesite añadir los demás parámetros a psql
curl -s https://raw.githubusercontent.com/GrupoQuanam/utils/refs/heads/main/neutralize_cloud_test.sql | psql
*/
do $$
declare
    nubefact              integer := 0;
    nubefact_credential   integer := 0;
    databusiness          integer := 0;
    carvajal              integer := 0;
    escon                 integer := 0;
    alicorp               integer := 0;
    interfono             integer := 0;
    multi_channel_sale    integer := 0;
    arin_rapi             integer := 0;
    pichihua_efact        integer := 0;
begin
    raise notice 'Borrando parámetros del sistema innecesarios para test';
    delete from ir_config_parameter where key in ('web.base.url.freeze');
    COMMIT;
    raise notice 'Deshabilitando facturación electronica';
    -- Para NubeFact
    SELECT count(1) into nubefact_credential FROM pg_catalog.pg_tables WHERE tablename = 'nubefact_credential';
    select count(1) into nubefact from information_schema.columns where table_name = 'res_company' and column_name = 'api_url';
    if nubefact_credential > 0 or nubefact > 0 then
        raise notice 'Nubefact Detectado';
        update ir_config_parameter set value='False' where key = 'enviar_automaticamente_al_cliente';
    end if;
    if nubefact_credential > 0 then
        delete from nubefact_credential where true;
    end if;
    if nubefact > 0 then
        update res_company set electronic_invoicing = False, api_url=null,api_token=null where true;
    end if;
    -- Para DataBusiness
    select count(1) into databusiness from information_schema.columns where table_name = 'res_company' and column_name = 'token_databusines';
    if databusiness > 0 then
        raise notice 'DataBusiness Detectado';
        update res_company set electronic_invoicing = False, token_databusines=null,url_databusines=null,
                               url_state_databusines=null,url_doc_databusines=null where true;
    end if;
    -- Para Carvajal Colombia
    select count(1) into carvajal from information_schema.columns where table_name = 'res_company' and column_name = 'l10n_co_edi_username';
    if carvajal > 0 then
        raise notice 'Carvajal Colombia Detectado';
        update res_company set l10n_co_edi_username=null, l10n_co_edi_password=null,l10n_co_edi_company=null,
                               l10n_co_edi_account=null where true;
    end if;
    -- Para Escon
    select count(1) into escon from information_schema.columns where table_name = 'res_company' and column_name = 'escon_url_01';
    if escon > 0 then
        raise notice 'Escon Detectado';
        update res_company set electronic_invoicing=False, escon_url_01=null,escon_url_02=null,escon_url_pdf=null,
                               escon_url_cdr=null,escon_url_xml=null,escon_user=null,escon_password=null where true;
    end if;
    -- Para Cia Sovos Alicorp
    delete from ir_config_parameter where key in ('cia.application_code', 'cia.base_host', 'cia.subscription_key');
    select count(1) into alicorp from ir_module_module where name = 'gq_cia_sovos' and state = 'installed';
    if alicorp > 0 then
        raise notice 'Cia Sovos(Alicorp) Detectado';
        delete from ir_config_parameter where key in ('gq_electronic_invoicing', 'simpliroute.active');
        raise notice 'Integración SimpliRoute deshabilitado';
        update res_company set electronic_invoicing = False where true;
    end if;
    -- Para Arin - FE Rapi
    select count(1) into arin_rapi from information_schema.columns where table_name = 'res_company' and column_name = 'osce_webservice';
    if arin_rapi > 0 then
        raise notice 'FE Rapi Detectado';
        update res_company set electronic_invoicing=False, electronic_billing_provider='other', osce_webservice=null, osce_user='MODDATOS', osce_password='MODDATOS' where true;
    end if;
    COMMIT;
    -- Para Pichihua - Efact
    select count(1) into pichihua_efact from information_schema.columns where table_name = 'res_company' and column_name = 'e_fact_url';
    if pichihua_efact > 0 then
        raise notice 'Pichihua - Efact Detectado';
        update res_company set electronic_invoicing=False, electronic_billing_provider=null, e_fact_url=null, e_fact_user='MODDATOS', e_fact_pass='MODDATOS' where true;
    end if;
    COMMIT;
    raise notice 'Deshabilitando acciones planificadas';
    update ir_cron set active = FALSE where true;
    COMMIT;
    raise notice 'Estableciendo noupdate a las acciones planificadas';
    update ir_model_data set noupdate = TRUE
    where model = 'ir.cron'
      and not ((module = 'base' and name = 'autovacuum_job')
      or (module = 'qa_localizaciones_peru_estandar' and name = 'cron_update_type_currency')
      or (module = 'qa_standard_locations_account' and name = 'cron_update_type_currency'));
    COMMIT;
    raise notice 'Habilitando acciones necesarias';
    update ir_cron
    set active = TRUE
    where id in (select res_id
                 from ir_model_data imd
                 where imd.model = 'ir.cron'
                   and (false
                     or (imd.module = 'base' and imd.name = 'autovacuum_job')
                     or (imd.module = 'account' and imd.name = 'ir_cron_auto_post_draft_entry')
                     or (imd.module = 'qa_localizaciones_peru_estandar' and imd.name = 'cron_update_type_currency')
                     or (imd.module = 'qa_standard_locations_account' and imd.name = 'cron_update_type_currency')
                     or (imd.module = 'qa_currency_revaluation' and imd.name = 'ir_cron_revert_difference_adjustments')
                     ));
    COMMIT;
    select count(1) into interfono from information_schema.columns where table_name = 'res_company' and column_name = 'db_connect';
    if interfono > 0 then
        raise notice 'ConceptoCom - Deshabilitando integración con Interfono';
        update res_company set db_connect=False where true;
    end if;

    SELECT count(1) into multi_channel_sale FROM pg_catalog.pg_tables WHERE tablename = 'multi_channel_sale';
    if multi_channel_sale > 0 then
        raise notice 'ConceptoCom - Deshabilitando integración con Magento';
        update multi_channel_sale set active=False,state='draft' where true;
    end if;
    COMMIT;
end $$;