@isTest
public class ProdutosDashControllerTests {
 	
    String debugMessage;
    Integer resultType;
    string companyId;
    string cnpj;
    boolean enviouTaxas;
    decimal boletoPagoFee;
    decimal boletoEmitidoFee;
    decimal boletoEmitidoPerc;
    decimal boletoPagoPerc;
    boolean boletoEnabled;
    decimal debitFee;
    decimal gatewayFee;
    boolean gatewayEnabled;
    decimal transferFee;
    decimal mdr1x;
    decimal mdr2x6x;
    decimal mdr7x12x;
    decimal mdr1xOtherBrands;
    decimal mdr2x6xOtherBrands;
    decimal mdr7x12xOtherBrands;
    decimal mcc;
    string versaoAPI;
    string billName;
    decimal antifraudeFee;
    boolean antifraudeEnabled;
    string antifraudeRiscoEnabled;
    decimal anticipationFee;
    string anticipationRiscoEnabled;
    decimal spotAnticipationFee;
    decimal anticipationVolume;
    decimal anticipationSpotVolume;
    string modeloDeAntecipacao;
    decimal anticipation1025;
    decimal anticipationdx;

    @isTest
    static void mockPuxarValores() {
        MockAPIPagarme.ProdutosDashPagarme = MockAPIPagarme.PRODUTOS_DASH;
    }

    @isTest 
    static void deveCadastrarCorretamente() {

        StApiLinkPagamentoPagarme apiPagarme = StApiLinkPagamentoPagarme.getInstance();
        
        Account acct = new Account(RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId());
        acct.Name = 'Standard teste';
        acct.CNPJ__c = '31203652000157';
        insert acct;

        Opportunity opp = MockObjectDigital.getOpportunity(acct);
        opp.Segmento__c = 'Alimentação e Bebidas';
        opp.Subsegmento__c = 'Alimentação Rápida';
        insert opp;
        
        Account pagarmeAcct = new Account(RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('PSP Client').getRecordTypeId());
        pagarmeAcct.ParentId = acct.Id;
        pagarmeAcct.Name = 'Pagarme teste';
        pagarmeAcct.CNPJ__c = '31203652000157';
        pagarmeAcct.AffiliationId__c = '5bc996c15e074ffa43292e5a';
        pagarmeAcct.FromOpportunity__c = opp.Id;
        pagarmeAcct.business_version__c = 'Pagar.me 1.0';
        insert pagarmeAcct;

        PagarmeProductDraft__c PMProd = new PagarmeProductDraft__c();
        PMProd.Opportunity__c = opp.Id;
        PMProd.Name = opp.Name;
        PMProd.AccountClient__c = pagarmeAcct.Id;
        PMProd.CreditCard__c = 'Yes';
        PMProd.RequestedAutomaticAnticipation__c = 'Yes';
        PMProd.RequestedBoleto__c = 'Yes';
        PMProd.RequestedClearSaleAntifraud__c = 'Yes';
        PMProd.RexLabAntifraud__c = 'Yes';
        PMProd.ResquestedGateway__c = 'Yes';
        PMProd.ClearSaleAntifraudFee__c = 1;
        PMProd.BoletoFee__c = 1;
        PMProd.Boleto_Emitido_Fee__c = 1;
        PMProd.Boleto_Emitido_Perc__c = 1;
        PMProd.Boleto_Pago_Perc__c = 1;
        PMProd.Pix_Pago_Fee__c = 1;
        PMProd.Pix_Gerado_Perc__c = 1;
        PMProd.Pix_Gerado_Perc__c = 1;
        PMProd.Pix_Pago_Perc__c = 1;
        PMProd.MDRDebit__c = 1;
        PMProd.GatewayTransactionFee__c = 1;
        PMProd.TransferFee__c = 1;
        PMProd.SpotAnticipationFeePercent__c = 2;
        PMProd.AutomaticAnticipationFeePercent__c = 1;
        PMProd.RequestedAnticipationModelVolume__c = 11;
        PMProd.RequestedSpotAnticipationVolume__c = 11;
        PMProd.MDR1x__c = 1;
        PMProd.MDR2x6x__c = 1;
        PMProd.MDR7x12x__c = 1;
        PMProd.Tem_garantia_de_chargeback__c = 'Sim';
        PMProd.Taxa_de_garantia_de_chargeback__c = 1;
        PMProd.Taxa_MDRZao_a_vista__c = 1;
        PMProd.Taxa_MDRZao_parcelas__c = 1;
        PMProd.Preco_MDRzao__c = 'Yes';
        PMProd.Dias_de_antecipacao__c  = 30;
        PMProd.Taxa_MDRZao_a_vista__c  = 3.79;
        PMProd.Taxa_MDRZao_parcelas__c  = 3.79;
        PMProd.mcc__c = 1799;
        PMProd.Versao_da_API__c = '2017-08-28';
        PMProd.Nome_da_Fatura__c = 'nome fatura';
        PMProd.RequestedAutomaticAnticipationModel__c = 'Antecipação Volume';
        PMProd.CNPJ_Liberado__c = true;
        PMProd.ApprovedAntifraud__c = 'On (Not allowed to turn-off)';
        PMProd.OwnerId = '00541000005y1V5AAI';
        
        insert PMProd;

        

        ApexPages.StandardController pmProdController = new ApexPages.StandardController(PMProd);
        ProdutosDashController controller = new ProdutosDashController(pmProdController);

        //companyId vazio
        pagarmeAcct.AffiliationId__c = null;
        update pagarmeAcct;
        controller.setupPagarmeProd(PMProd.Id);
        controller.enviarProdutosDashPagarme();

        //erro infos cadastro vazias
        pagarmeAcct.AffiliationId__c = '5bc996c15e074ffa43292e5a';
        update pagarmeAcct;
        PMProd.mcc__c = null;
        update PMProd;
        controller.setupPagarmeProd(PMProd.Id);
        controller.enviarProdutosDashPagarme();

        //erro infos cadastro vazias
        PMProd.mcc__c = 1799;
        PMProd.BoletoFee__c = null;
        PMProd.MDRDebit__c = null;
        PMProd.GatewayTransactionFee__c = null;
        PMProd.TransferFee__c = null;
        PMProd.MDR1x__c = 1;
        PMProd.MDR2x6x__c = 1;
        PMProd.MDR7x12x__c = 1;
        update PMProd;
        
        controller.setupPagarmeProd(PMProd.Id);
        Test.StartTest();
        controller.enviarProdutosDashPagarme();
        

        //modelo de antecipação 1025
        PMProd.AntifraudFee__c = 1;
        PMProd.BoletoFee__c = 1;
        PMProd.Boleto_Emitido_Fee__c = 1;
        PMProd.Boleto_Emitido_Perc__c = 1;
        PMProd.Boleto_Pago_Perc__c = 1;
        PMProd.MDRDebit__c = 1;
        PMProd.GatewayTransactionFee__c = 1;
        PMProd.TransferFee__c = 1;
        PMProd.AutomaticAnticipationFeePercent__c = 1;
        PMProd.RequestedAnticipationModelVolume__c = 90;
        PMProd.RequestedAutomaticAnticipationModel__c = 'Antecipação 1025';
        PMProd.ApprovedAutomaticAnticipation__c = 'Sale';
        PMProd.MDR1x__c = 1;
        PMProd.MDR2x6x__c = 1;
        PMProd.MDR7x12x__c = 1;
        update PMProd;
        
        controller.setupPagarmeProd(PMProd.Id);
        controller.enviarProdutosDashPagarme();
        
        //modelo de antecipação d+x
        PMProd.RequestedAutomaticAnticipationModel__c = 'Antecipação d+x';
        PMProd.AnticipationModelDays__c = 30;
        PMProd.ApprovedAnticipationModelDays__c = 15;
        update PMProd;

        controller.setupPagarmeProd(PMProd.Id);
        
        controller.enviarProdutosDashPagarme();
        Test.StopTest();
        //modelo de antecipação Spot
        PMProd.RequestedAutomaticAnticipationModel__c = 'Antecipação Spot';
        PMProd.RequestedAutomaticAnticipation__c = 'No';
        PMProd.SpotAnticipationFeePercent__c = 2;
        PMProd.ApprovedSpotVolume__c = 1;
        update PMProd;
        controller.setupPagarmeProd(PMProd.Id);
        controller.enviarProdutosDashPagarme();
        
        PMProd.ApprovedSpotVolume__c = 100;
        update PMProd;
        controller.setupPagarmeProd(PMProd.Id);
        controller.enviarProdutosDashPagarme();
    }
    
    @isTest 
    static void deveCadastrarCorretamente2() {

        StApiLinkPagamentoPagarme apiPagarme = StApiLinkPagamentoPagarme.getInstance();
        
        Account acct = new Account(RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId());
        acct.Name = 'Standard teste';
        acct.CNPJ__c = '31203652000157';
        insert acct;

        Opportunity opp = MockObjectDigital.getOpportunity(acct);
        opp.Segmento__c = 'Alimentação e Bebidas';
        opp.Subsegmento__c = 'Alimentação Rápida';
        insert opp;
        
        Account pagarmeAcct = new Account(RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('PSP Client').getRecordTypeId());
        pagarmeAcct.ParentId = acct.Id;
        pagarmeAcct.Name = 'Pagarme teste';
        pagarmeAcct.CNPJ__c = '31203652000157';
        pagarmeAcct.AffiliationId__c = '5bc996c15e074ffa43292e5a';
        pagarmeAcct.FromOpportunity__c = opp.Id;
        pagarmeAcct.business_version__c = 'Pagar.me 1.0';
        insert pagarmeAcct;        

        PagarmeProductDraft__c PMProd = new PagarmeProductDraft__c();
        PMProd.Opportunity__c = opp.Id;
        PMProd.Name = opp.Name;
        PMProd.AccountClient__c = pagarmeAcct.Id;
        PMProd.CreditCard__c = 'Yes';
        PMProd.RequestedAutomaticAnticipation__c = 'Yes';
        PMProd.RequestedBoleto__c = 'Yes';
        PMProd.RequestedClearSaleAntifraud__c = 'Yes';
        PMProd.RexLabAntifraud__c = 'Yes';
        PMProd.ResquestedGateway__c = 'Yes';
        PMProd.ClearSaleAntifraudFee__c = 1;
        PMProd.BoletoFee__c = 1;
        PMProd.Boleto_Emitido_Fee__c = 1;
        PMProd.Boleto_Emitido_Perc__c = 1;
        PMProd.Boleto_Pago_Perc__c = 1;
        PMProd.MDRDebit__c = 1;
        PMProd.GatewayTransactionFee__c = 1;
        PMProd.TransferFee__c = 1;
        PMProd.AutomaticAnticipationFeePercent__c = 1;
        PMProd.RequestedAnticipationModelVolume__c = 11;
        PMProd.RequestedSpotAnticipationVolume__c = 11;
        PMProd.MDR1x__c = 1;
        PMProd.MDR2x6x__c = 1;
        PMProd.MDR7x12x__c = 1;
        PMProd.Tem_garantia_de_chargeback__c = 'Não';
        PMProd.Taxa_de_garantia_de_chargeback__c = 1;
        PMProd.Taxa_MDRZao_a_vista__c = 1;
        PMProd.Taxa_MDRZao_parcelas__c = 1;
        PMProd.Preco_MDRzao__c = 'No';
        PMProd.mcc__c = 1799;
        PMProd.Versao_da_API__c = '2017-08-28';
        PMProd.Nome_da_Fatura__c = 'nome fatura';
        PMProd.RequestedAutomaticAnticipationModel__c = 'Antecipação Volume';
        PMProd.CNPJ_Liberado__c = true;
        PMProd.ApprovedAntifraud__c = 'On (Not allowed to turn-off)';
        PMProd.ApprovedAutomaticAnticipation__c = 'Volume';
        insert PMProd;
        
        ApexPages.StandardController pmProdController = new ApexPages.StandardController(PMProd);
        ProdutosDashController controller = new ProdutosDashController(pmProdController);

        //modelo de antecipação Spot
        PMProd.RequestedAutomaticAnticipationModel__c = 'Antecipação Spot';
        PMProd.RequestedAutomaticAnticipation__c = 'No';
        PMProd.SpotAnticipationFeePercent__c = 2;
        update PMProd;
        controller.setupPagarmeProd(PMProd.Id);
        controller.enviarProdutosDashPagarme();
        
        PMProd.RequestedAutomaticAnticipation__c = 'Yes';
        PMProd.RequestedSpotAnticipationVolume__c = 11;
        PMProd.ApprovedSpotVolume__c = 20;
        update PMProd;
        controller.setupPagarmeProd(PMProd.Id);
        controller.enviarProdutosDashPagarme();
        
        PMProd.Preco_MDRzao__c = 'Yes';
        PMProd.Dias_de_antecipacao__c = 30;
        update PMProd;
        controller.setupPagarmeProd(PMProd.Id);
        controller.enviarProdutosDashPagarme();
    }
    
        
    @isTest 
    static void validacaoSegmentoGarantia() {

        StApiLinkPagamentoPagarme apiPagarme = StApiLinkPagamentoPagarme.getInstance();
        
        Account acct = new Account(RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId());
        acct.Name = 'Standard teste';
        acct.CNPJ__c = '31203652000157';
        insert acct;

        Opportunity opp = MockObjectDigital.getOpportunity(acct);
        opp.Segmento__c = 'Eletroeletrônicos';
        opp.Subsegmento__c = 'Eletrônicos';
        insert opp;
        
        Account pagarmeAcct = new Account(RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('PSP Client').getRecordTypeId());
        pagarmeAcct.ParentId = acct.Id;
        pagarmeAcct.Name = 'Pagarme teste';
        pagarmeAcct.CNPJ__c = '31203652000157';
        pagarmeAcct.AffiliationId__c = '5bc996c15e074ffa43292e5a';
        pagarmeAcct.FromOpportunity__c = opp.Id;
        pagarmeAcct.business_version__c = 'Pagar.me 1.0';
        insert pagarmeAcct;        

        PagarmeProductDraft__c PMProd = new PagarmeProductDraft__c();
        PMProd.Opportunity__c = opp.Id;
        PMProd.Name = opp.Name;
        PMProd.AccountClient__c = pagarmeAcct.Id;
        PMProd.CreditCard__c = 'Yes';
        PMProd.RequestedAutomaticAnticipation__c = 'Yes';
        PMProd.RequestedBoleto__c = 'Yes';
        PMProd.RequestedClearSaleAntifraud__c = 'Yes';
        PMProd.RexLabAntifraud__c = 'Yes';
        PMProd.ResquestedGateway__c = 'Yes';
        PMProd.ClearSaleAntifraudFee__c = 1;
        PMProd.BoletoFee__c = 1;
        PMProd.Boleto_Emitido_Fee__c = 1;
        PMProd.Boleto_Emitido_Perc__c = 1;
        PMProd.Boleto_Pago_Perc__c = 1;
        PMProd.MDRDebit__c = 1;
        PMProd.GatewayTransactionFee__c = 1;
        PMProd.TransferFee__c = 1;
        PMProd.AutomaticAnticipationFeePercent__c = 1;
        PMProd.RequestedAnticipationModelVolume__c = 11;
        PMProd.RequestedSpotAnticipationVolume__c = 11;
        PMProd.MDR1x__c = 1;
        PMProd.MDR2x6x__c = 1;
        PMProd.MDR7x12x__c = 1;
        PMProd.Tem_garantia_de_chargeback__c = 'Sim';
        PMProd.Taxa_de_garantia_de_chargeback__c = 1;
        PMProd.Taxa_MDRZao_a_vista__c = 1;
        PMProd.Taxa_MDRZao_parcelas__c = 1;
        PMProd.Preco_MDRzao__c = 'No';
        PMProd.mcc__c = 1799;
        PMProd.Versao_da_API__c = '2017-08-28';
        PMProd.Nome_da_Fatura__c = 'nome fatura';
        PMProd.RequestedAutomaticAnticipationModel__c = 'Antecipação Volume';
        PMProd.CNPJ_Liberado__c = true;
        PMProd.ApprovedAntifraud__c = 'On (Not allowed to turn-off)';
        PMProd.ApprovedAutomaticAnticipation__c = 'Volume';
        insert PMProd;
        
        ApexPages.StandardController pmProdController = new ApexPages.StandardController(PMProd);
        ProdutosDashController controller = new ProdutosDashController(pmProdController);
        
        controller.setupPagarmeProd(PMProd.Id);
        controller.enviarProdutosDashPagarme();
               
        opp.Segmento__c = 'Jogos e Brinquedos';
        opp.Subsegmento__c = 'Jogos Digitais';
        update opp;
        controller.setupPagarmeProd(PMProd.Id);
        controller.enviarProdutosDashPagarme();
                       
        opp.Segmento__c = 'Ingressos, Eventos e Festas';
        opp.Subsegmento__c = 'Ingressos';
        update opp;
        controller.setupPagarmeProd(PMProd.Id);
        controller.enviarProdutosDashPagarme();
                               
        opp.Segmento__c = 'Entretenimento e Turismo';
        opp.Subsegmento__c = 'Entretenimento e Turismo';
        update opp;
        controller.setupPagarmeProd(PMProd.Id);
        controller.enviarProdutosDashPagarme();
    }
}