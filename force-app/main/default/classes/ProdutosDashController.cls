public class ProdutosDashController {

    public PagarmeProductDraft__c pagarmeProd { get; set; }
    private StApiLinkPagamentoPagarme stApiPagarme;
        
    //Alert
    private static final Integer SUCCESS = 0;
    private static final Integer WARNING = 1;
    private static final Integer ERROR = 2;
    public String debugMessage { get; set; }
    public Integer resultType { get; set; }

    public String companyId { get; set; }
    public String cnpj { get; set; }
    public boolean enviouTaxas { get; set; }
    public Decimal PorcentagemDash { get; set; }
    
    public decimal boletoPagoFee { get; set; }
    public decimal boletoEmitidoFee { get; set; }
    public decimal boletoEmitidoPerc { get; set; }
    public decimal boletoPagoPerc { get; set; }
    public boolean boletoEnabled { get; set; }
    public boolean pixEnabled { get; set; }
    public decimal pixPagoFee { get; set; }
    public decimal pixGeradoFee { get; set; }
    public decimal pixGeradoPerc { get; set; }
    public decimal pixPagoPerc { get; set; }
    public decimal debitFee { get; set; }
    public decimal gatewayFee { get; set; }
    public boolean gatewayEnabled { get; set; }
    public decimal transferFee { get; set; }
    public decimal fraudCoveredFee { get; set; }
    public string segmento { get; set; }
    public string JsonGarantia { get; set; }
    public String JsonAntifraudSeg { get; set; }
    public decimal diasAntecipacaoMDRzao { get; set; }
    public decimal mdr1x { get; set; }
    public decimal mdr2x6x { get; set; }
    public decimal mdr7x12x { get; set; }
    public decimal mdr1xOtherBrands { get; set; }
    public decimal mdr2x6xOtherBrands { get; set; }
    public decimal mdr7x12xOtherBrands { get; set; }
    public decimal mdrzaoAVista { get; set; }
    public decimal mdrzaoParcelas { get; set; }
    public string temMdrzao { get; set; }
    public decimal mcc { get; set; }
    public string versaoAPI { get; set; }
    public string billName { get; set; }
    public decimal antifraudeFee { get; set; }
    public boolean antifraudeEnabled { get; set; }
    public decimal anticipationFee { get; set; }
    public string modeloDeAntecipacao { get; set; }
    public string anticipationType { get; set; }
    public boolean liberou { get; set; }

    public ProdutosDashController(ApexPages.StandardController stdController) {
        
        this.pagarmeProd = (PagarmeProductDraft__c) stdController.getRecord();
        stApiPagarme = StApiLinkPagamentoPagarme.getInstance();
        
        setupPagarmeProd(PagarmeProd.Id);
    }
    
    public void setupPagarmeProd(id pagarmeProdId) {
        
        PagarmeProductDraft__c pagarmeProd = [SELECT Id, Account__c, Opportunity__c, BoletoFee__c, MDRDebit__c, GatewayTransactionFee__c, TransferFee__c, MDR1x__c,
                                              Taxa_MDRZao_a_vista__c, Taxa_MDRZao_parcelas__c, MDR2x6x__c, MDR7x12x__c, MDR1xOtherBrands__c, MDR2x6xOtherBrands__c,
                                              MDR7x12xOtherBrands__c, mcc__c, Nome_da_Fatura__c, Versao_da_API__c, AccountClient__c, ClearSaleAntifraudFee__c,
                                              AutomaticAnticipationFeePercent__c, ApprovedAntifraud__c, RequestedClearSaleAntifraud__c, ApprovedAutomaticAnticipation__c,
                                              SpotAnticipationFeePercent__c, RequestedSpotAnticipationVolume__c, RequestedAnticipationModelVolume__c,
                                              AnticipationModelDays__c, Preco_MDRzao__c, RequestedAutomaticAnticipationModel__c, Enviou_Taxas_Comercial__c,
                                              RequestedAutomaticAnticipation__c, Libera_alteracao__c, Boleto_Emitido_Fee__c, Boleto_Emitido_Perc__c, Boleto_Pago_Perc__c, 
                                              Tem_garantia_de_chargeback__c, Taxa_de_garantia_de_chargeback__c, Pix_Gerado_Perc__c, Pix_Gerado_Fee__c, Pix_Pago_Perc__c,
                                              Pix_Pago_Fee__c, Dias_de_antecipacao__c
                                              FROM PagarmeProductDraft__c WHERE Id =: pagarmeProdId LIMIT 1];
        
        Opportunity oppt = [SELECT Id, RecordtypeId, Recordtype.Name, Segmento__c, Subsegmento__c
                            FROM Opportunity WHERE Id =: pagarmeProd.Opportunity__c];
        
        if (oppt.RecordType.Name != 'Upsell' && oppt.RecordType.Name != 'Churn Reversion') {
            Account PagarmeClient = [SELECT Id, CNPJ__c, AffiliationId__c, FromOpportunity__c
                                     FROM Account WHERE Id =: pagarmeProd.AccountClient__c LIMIT 1];
            
            cnpj = PagarmeClient.CNPJ__c;
            companyId = PagarmeClient.AffiliationId__c;
        }
        else if (oppt.RecordType.Name == 'Upsell' || oppt.RecordType.Name == 'Churn Reversion') {
            Account ParentAccount = [SELECT Id, CNPJ__c, AffiliationId__c, FromOpportunity__c
                                     FROM Account WHERE Id =: pagarmeProd.Account__c LIMIT 1];
            
            cnpj = ParentAccount.CNPJ__c;
            companyId = ParentAccount.AffiliationId__c;
        }
        
        enviouTaxas = pagarmeProd.Enviou_Taxas_Comercial__c;
        liberou = pagarmeProd.Libera_alteracao__c;
        
        segmento = oppt.Subsegmento__c;
        mcc = pagarmeProd.mcc__c;
        versaoAPI = pagarmeProd.Versao_da_API__c;
        modeloDeAntecipacao = pagarmeProd.RequestedAutomaticAnticipationModel__c;
        
        //Nome da fatura
        billName = pagarmeProd.Nome_da_Fatura__c;
        if (billName != null) {
            billName = pagarmeProd.Nome_da_Fatura__c.toLowerCase();
            billName = billName.replaceAll('á','a');
            billName = billName.replaceAll('à','a');
            billName = billName.replaceAll('â','a');
            billName = billName.replaceAll('ã','a');
            billName = billName.replaceAll('ä','a');
            billName = billName.replaceAll('é','e');
            billName = billName.replaceAll('è','e');
            billName = billName.replaceAll('ê','e');
            billName = billName.replaceAll('í','i');
            billName = billName.replaceAll('ì','i');
            billName = billName.replaceAll('î','i');
            billName = billName.replaceAll('ó','o');
            billName = billName.replaceAll('ò','o');
            billName = billName.replaceAll('ô','o');
            billName = billName.replaceAll('õ','o');
            billName = billName.replaceAll('ú','u');
            billName = billName.replaceAll('ù','u');
            billName = billName.replaceAll('û','u');
            billName = billName.replaceAll('ç','c');
            billName = billName.replaceAll('-',' ');
            billName = billName.replaceAll('\'','');
            billName = billName.replaceAll('&','e');
            billName = billName.replaceAll('$','');
        }
        
        // Taxas MDRzao
        mdrzaoAVista = pagarmeProd.Taxa_MDRZao_a_vista__c;
        mdrzaoParcelas = pagarmeProd.Taxa_MDRZao_parcelas__c;
        temMdrzao = pagarmeProd.Preco_MDRzao__c;
        diasAntecipacaoMDRzao = pagarmeProd.Dias_de_antecipacao__c;
        
        // Taxas MDRs
        mdr1x = pagarmeProd.MDR1x__c;
        mdr2x6x = pagarmeProd.MDR2x6x__c;
        mdr7x12x = pagarmeProd.MDR7x12x__c;
        mdr1xOtherBrands = pagarmeProd.MDR1xOtherBrands__c;
        mdr2x6xOtherBrands = pagarmeProd.MDR2x6xOtherBrands__c;
        mdr7x12xOtherBrands = pagarmeProd.MDR7x12xOtherBrands__c;
        
        if (mdr1xOtherBrands == null && mdr2x6xOtherBrands == null && mdr7x12xOtherBrands == null) {
            mdr1xOtherBrands = pagarmeProd.MDR1x__c;
            mdr2x6xOtherBrands = pagarmeProd.MDR2x6x__c;
            mdr7x12xOtherBrands = pagarmeProd.MDR7x12x__c;
        }
        
        //Taxas Boleto
        boletoEmitidoFee = pagarmeProd.Boleto_Emitido_Fee__c;
        if (boletoEmitidoFee != null) {boletoEmitidoFee = (pagarmeProd.Boleto_Emitido_Fee__c * 100);}
        boletoEmitidoPerc = pagarmeProd.Boleto_Emitido_Perc__c;
        boletoPagoFee = pagarmeProd.BoletoFee__c;
        if (boletoPagoFee != null) {boletoPagoFee = (pagarmeProd.BoletoFee__c * 100);}
        boletoPagoPerc = pagarmeProd.Boleto_Pago_Perc__c;
        
        if (boletoPagoFee == null && boletoPagoPerc == null && boletoEmitidoFee == null && boletoEmitidoPerc == null) {
            boletoEnabled = false;
        }
        if (boletoPagoFee != null || boletoPagoPerc != null || boletoEmitidoFee != null || boletoEmitidoPerc != null) {
            boletoEnabled = true;
        }
                
        //Taxas PIX
        pixGeradoFee = pagarmeProd.Pix_Gerado_Fee__c;
        if (pixGeradoFee != null) {pixGeradoFee = (pagarmeProd.Pix_Gerado_Fee__c * 100);}
        pixGeradoPerc = pagarmeProd.Pix_Gerado_Perc__c;
        pixPagoFee = pagarmeProd.Pix_Pago_Fee__c;
        if (pixPagoFee != null) {pixPagoFee = (pagarmeProd.Pix_Pago_Fee__c * 100);}
        pixPagoPerc = pagarmeProd.Pix_Pago_Perc__c;
        
        // Validação para tirar o valor default de Pix no Pagar.me - PALIATIVO
        if (pixPagoFee != null && pixPagoPerc == null) {pixPagoPerc = 0;}
                
        if (pixGeradoFee != null || pixPagoFee != null || pixGeradoPerc != null || pixPagoPerc != null) {
            pixEnabled = true;
        }
        if (pixGeradoFee == null && pixPagoFee == null && pixGeradoPerc == null && pixPagoPerc == null) {
            pixEnabled = false;
        }
                    
        //Taxa gateway
        gatewayFee = pagarmeProd.GatewayTransactionFee__c;
        if (gatewayFee != null) {
            gatewayFee = (pagarmeProd.GatewayTransactionFee__c * 100);
            gatewayEnabled = true;
        }
        else if (gatewayFee == null) {
            gatewayFee = pagarmeProd.GatewayTransactionFee__c;
            gatewayEnabled = false;
        }
        
        //Taxa transferência
        transferFee = pagarmeProd.TransferFee__c;
        if (transferFee != null) {
            transferFee = (pagarmeProd.TransferFee__c * 100);
        }
        else if (transferFee == null) {
            transferFee = pagarmeProd.TransferFee__c;
        }
                
        //Taxa débito
        debitFee = pagarmeProd.MDRDebit__c;
        if (debitFee != null) {
            debitFee = (pagarmeProd.MDRDebit__c * 100);
        }
        else if (debitFee == null) {
            debitFee = pagarmeProd.MDRDebit__c;
        }
        
        // Taxa Garantia Chargeback
        fraudCoveredFee = pagarmeProd.Taxa_de_garantia_de_chargeback__c;
        if (pagarmeProd.Tem_garantia_de_chargeback__c == 'Sim') {
            if (fraudCoveredFee != null || fraudCoveredFee != 0) {
                fraudCoveredFee = (pagarmeProd.Taxa_de_garantia_de_chargeback__c / 100);
                JsonGarantia = '"fraud_covered": true, '
                    + '\n' + '"fraud_coverage_fee": ' + fraudCoveredFee + ', ';
            }
            else if (fraudCoveredFee == null || fraudCoveredFee == 0) {
                fraudCoveredFee = pagarmeProd.Taxa_de_garantia_de_chargeback__c;
                JsonGarantia = '"fraud_covered": false, '
                    + '\n' + '"fraud_coverage_fee": ' + fraudCoveredFee + ', ';
            }
        }
        else {
            fraudCoveredFee = pagarmeProd.Taxa_de_garantia_de_chargeback__c;
            JsonGarantia = '';
        }
        
        //Taxa antifraude
        antifraudeFee = pagarmeProd.ClearSaleAntifraudFee__c;
        if (((pagarmeProd.ApprovedAntifraud__c == 'On (Allowed to turn-off)' || pagarmeProd.ApprovedAntifraud__c == 'On (Not allowed to turn-off)') && pagarmeProd.RequestedClearSaleAntifraud__c == 'No')
           || (pagarmeProd.ApprovedAntifraud__c != 'Off' && pagarmeProd.RequestedClearSaleAntifraud__c == 'Yes')) {
            if (pagarmeProd.ClearSaleAntifraudFee__c != null) {
                antifraudeFee = (pagarmeProd.ClearSaleAntifraudFee__c * 100);
                antifraudeEnabled = true;
            }
            else if (pagarmeProd.ClearSaleAntifraudFee__c == null) {
                antifraudeFee = 70;
                antifraudeEnabled = true;
            }
        }
        else if (pagarmeProd.RequestedClearSaleAntifraud__c == 'No' && pagarmeProd.ApprovedAntifraud__c == 'Off') {
            antifraudeFee = null;
            antifraudeEnabled = false;
        }
        
        //Taxas e modelos de antecipação
        anticipationType = '';
        anticipationFee = (pagarmeProd.AutomaticAnticipationFeePercent__c == null ? null : pagarmeProd.AutomaticAnticipationFeePercent__c);

        if (pagarmeProd.RequestedAutomaticAnticipation__c == 'Yes') {
            
            if (modeloDeAntecipacao == 'Antecipação 1025') {
                anticipationType = '"automatic_1025_anticipation": ' + pagarmeProd.AnticipationModelDays__c + ', ';
                anticipationFee = pagarmeProd.AutomaticAnticipationFeePercent__c;
            }
            else if (modeloDeAntecipacao == 'Antecipação d+x') {
                anticipationType = '"automatic_dx_anticipation": ' + pagarmeProd.AnticipationModelDays__c + ', ';
                anticipationFee = pagarmeProd.AutomaticAnticipationFeePercent__c;
            }
            else if (modeloDeAntecipacao == 'Antecipação Volume') {
                anticipationType = '"automatic_volume_anticipation": ' + pagarmeProd.RequestedAnticipationModelVolume__c + ', ';
                anticipationFee = pagarmeProd.AutomaticAnticipationFeePercent__c;
            }
            else if (modeloDeAntecipacao == 'Antecipação Spot') {
                anticipationType = '"spot_anticipation": ' + pagarmeProd.RequestedSpotAnticipationVolume__c + ', ';
                anticipationFee = pagarmeProd.SpotAnticipationFeePercent__c;
            }
        }
        else if (pagarmeProd.RequestedAutomaticAnticipation__c == 'No') {
            if (modeloDeAntecipacao == 'Antecipação Spot') {
                anticipationType = '"spot_anticipation": ' + pagarmeProd.RequestedSpotAnticipationVolume__c + ', ';
                anticipationFee = pagarmeProd.SpotAnticipationFeePercent__c;
            }
        }
    }
    
    public String enviarProdutosDashPagarme() {
        
        PagarmeProductDraft__c PmProd = [SELECT Id,Preco_MDRzao__c, Opportunity__c, Enviou_Taxas_Comercial__c, CNPJ_Liberado__c, RequestedClearSaleAntifraud__c, ApprovedAntifraud__c,
                                         RequestedAutomaticAnticipation__c, ApprovedAutomaticAnticipation__c, AnticipationModelDays__c, RequestedAnticipationModelVolume__c,
                                         ApprovedAnticipationModelDays__c, ApprovedAnticipationModelVolume__c, RequestedSpotAnticipationVolume__c, ApprovedSpotVolume__c,
                                         Tem_garantia_de_chargeback__c, Opportunity__r.StageName, Taxa_de_garantia_de_chargeback__c,
                                         Dias_de_antecipacao__c, Owner.Profile.Name, Status__c
                                         FROM PagarmeProductDraft__c WHERE Id =: PagarmeProd.Id LIMIT 1];
                
        Opportunity oppt = [SELECT Id, RecordtypeId, Recordtype.Name, Segmento__c, Subsegmento__c
                            FROM Opportunity WHERE Id =: PmProd.Opportunity__c];
        
        User u = [SELECT Id, Email, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
                
        String body;
                
        // De-Para de Segmentos (Subsegment SF -> Pagarme Segment)
        PagarmeAntifraudSegment pagarmeAntifraud = new PagarmeAntifraudSegment();
        String segmentoPagarme = pagarmeAntifraud.deParaSegmentosPagarme(oppt.Subsegmento__c);        

        if (companyId == null || cnpj == null) {
            debugMessage = 'Necessário conta filha pagarme com CNPJ e CompanyId Cadastrado! Caso seja upsell ou churn reversion da Pagar.me, a client fica no campo "Account".';
            resultType = WARNING;
        }
        
        // Não é possível simular o preço quando a opp já está ganha
        else if (PmProd.Opportunity__r.StageName == 'Won') {
            debugMessage = 'Você não pode simular o preço de um product de uma oportunidade que já está ganha.';
            resultType = WARNING;      
        }
        else if (billName == null || versaoAPI == null || mcc == null) {
            debugMessage = 'Necessário cadastrar Nome da Fatura, mcc e Versão da API !';
            resultType = WARNING;
        }
        else if (gatewayFee == null && debitFee == null && boletoPagoFee == null && transferFee == null && mdr1x == null && mdr2x6x == null && mdr7x12x == null) {
            debugMessage = 'Cadastre ao menos uma taxa no produto !';
            resultType = WARNING;
        }
        else if ((modeloDeAntecipacao == 'Antecipação 1025' || modeloDeAntecipacao == 'Antecipação d+x') && (PmProd.AnticipationModelDays__c == null || anticipationFee == null)) {
            debugMessage = 'Necessário cadastrar o preço e dia do modelo !';
            resultType = WARNING;
        }
        else if (modeloDeAntecipacao == 'Antecipação Volume' && (PmProd.RequestedAnticipationModelVolume__c == null || anticipationFee == null)) {
            debugMessage = 'Necessário cadastrar o preço e o volume do modelo !';
            resultType = WARNING;
        }
        else if (modeloDeAntecipacao == 'Antecipação Spot' && (PmProd.RequestedSpotAnticipationVolume__c == null || anticipationFee == null)) {
            debugMessage = 'Necessário cadastrar o preço e o volume do modelo !';
            resultType = WARNING;
        }
        else if (PmProd.Tem_garantia_de_chargeback__c == 'Sim' && fraudCoveredFee == null) {
            debugMessage = 'Necessário cadastrar o preço de Garantia de Chargeback !';
            resultType = WARNING;
        }
        
        // Segmento Proibido Garantia CBK -> "electronics"
        else if (PmProd.Tem_garantia_de_chargeback__c == 'Sim' && segmentoPagarme == 'electronics') {
            debugMessage = 'Não é possível a Configuração de Garantia para o Segmento "electronics" !';
            resultType = WARNING;            
        }
        // Segmento Proibido Garantia CBK -> "digital_games"; "videogames"
        else if (PmProd.Tem_garantia_de_chargeback__c == 'Sim' && segmentoPagarme == 'videogames') {
            debugMessage = 'Não é possível a Configuração de Garantia para o Segmento "videogames" !';
            resultType = WARNING;            
        }
        // Segmento Proibido Garantia CBK -> "tickets"
        else if (PmProd.Tem_garantia_de_chargeback__c == 'Sim' && segmentoPagarme == 'tickets') {
            debugMessage = 'Não é possível a Configuração de Garantia para o Segmento "tickets" !';
            resultType = WARNING;            
        }
        // Segmento Proibido Garantia CBK -> "tourism"
        else if (PmProd.Tem_garantia_de_chargeback__c == 'Sim' && segmentoPagarme == 'tourism') {
            debugMessage = 'Não é possível a Configuração de Garantia para o Segmento "tourism" !';
            resultType = WARNING;            
        }       
        
        ////////////////////////
        
        // Trava de pricing
        /*else if (oppt.RecordType.Name != 'Upsell' && oppt.RecordType.Name != 'Churn Reversion' && (PmProd.Owner.Profile.Name == 'Inside Sales' || PmProd.Owner.Profile.Name == 'Field Sales'|| PmProd.Owner.Profile.Name == 'Farmer' || PmProd.Owner.Profile.Name == 'Farming Account Manager') && PmProd.Status__c != 'Aprovado'){
            debugMessage = 'O Product deve estar com Status "Aprovado" para cadastrar as taxas.';
            resultType = WARNING;
        }*/
        
        // Aprovado por Risco
        else if(PmProd.CNPJ_Liberado__c <> true) {
            debugMessage = 'O CNPJ do seu Cliente não foi Aprovado !';
            resultType = WARNING;
        }
        
        // Validação Risco - Antifraude
        else if(PmProd.RequestedClearSaleAntifraud__c == 'No' && PmProd.ApprovedAntifraud__c <> 'Off') {
            debugMessage = 'O Antifraude do seu Cliente não foi Liberado para ser Desligado. Peça Aprovação de Risco.';
            resultType = WARNING;
        }
        else if(PmProd.RequestedClearSaleAntifraud__c == 'Yes' && PmProd.ApprovedAntifraud__c == 'Off') {
            debugMessage = 'O Antifraude do seu Cliente não foi Liberado para ser Ligado. Peça Aprovação de Risco.';
            resultType = WARNING;
        }
        
        // Validação Risco - Antecipação
        else if(PmProd.RequestedAutomaticAnticipation__c == 'Yes' && PmProd.ApprovedAutomaticAnticipation__c == 'Not Approved') {
            debugMessage = 'Seu Product não teve a Antecipação Automática Aprovada. Peça Aprovação de Risco.';
            resultType = WARNING;
        }
        
        // Validação Risco - Antecipação d+x
        else if(PmProd.RequestedAutomaticAnticipation__c == 'Yes' && (modeloDeAntecipacao == 'Antecipação 1025' || modeloDeAntecipacao == 'Antecipação d+x') && PmProd.AnticipationModelDays__c <> null && PmProd.ApprovedAutomaticAnticipation__c <> 'Sale') {
            debugMessage = 'Antecipação de Automática em dias não Aprovada. Peça Aprovação de Risco.';
            resultType = WARNING;
        }
        else if(PmProd.RequestedAutomaticAnticipation__c == 'Yes' && (modeloDeAntecipacao == 'Antecipação 1025' || modeloDeAntecipacao == 'Antecipação d+x') && PmProd.AnticipationModelDays__c <> null && (PmProd.AnticipationModelDays__c < PmProd.ApprovedAnticipationModelDays__c)) {
            debugMessage = 'Você não pode Solicitar um Modelo de Antecipação em dias Menor do que o Aprovado por Risco. Ajuste o seu Product Pagar.me ou Peça Aprovação de Risco.';
            resultType = WARNING;
        }
        else if(PmProd.RequestedAutomaticAnticipation__c == 'Yes' && (modeloDeAntecipacao == 'Antecipação 1025' || modeloDeAntecipacao == 'Antecipação d+x') && PmProd.AnticipationModelDays__c <> null && PmProd.ApprovedAnticipationModelDays__c == null) {
            debugMessage = 'O Modelo de Antecipação Automático (em dias) Solicitado não foi Aprovado por Risco. Ajuste o seu Product Pagar.me ou peça Aprovação de Risco.';
            resultType = WARNING;
        }
        
        // Validação Risco - Antecipação MDRZão
        else if(PmProd.Preco_MDRzao__c  == 'Yes' && PmProd.Dias_de_antecipacao__c  <> null && (PmProd.Dias_de_antecipacao__c  < PmProd.ApprovedAnticipationModelDays__c)) {
            debugMessage = 'O Modelo de Antecipação de MDRZão Solicitado não foi Aprovado por Risco. Ajuste o seu Product Pagar.me ou peça Aprovação de Risco.';
            resultType = WARNING;
        }
        
        // Validação Risco - Antecipação Volume                
        else if(PmProd.RequestedAutomaticAnticipation__c == 'Yes' && modeloDeAntecipacao == 'Antecipação Volume' && PmProd.RequestedAnticipationModelVolume__c <> null && PmProd.ApprovedAutomaticAnticipation__c <> 'Volume') {
            debugMessage = 'Antecipação de Automática por Volume não Aprovada. Peça Aprovação de Risco.';
            resultType = WARNING;
        }                
        else if(PmProd.RequestedAutomaticAnticipation__c == 'Yes' && modeloDeAntecipacao == 'Antecipação Volume' && PmProd.RequestedAnticipationModelVolume__c <> null && (PmProd.RequestedAnticipationModelVolume__c > PmProd.ApprovedAnticipationModelVolume__c)) {
            debugMessage = 'Você não pode Solicitar um Modelo de Antecipação Volume Maior do que o Aprovado por Risco. Ajuste o seu Product Pagar.me ou peça Aprovação de Risco.';
            resultType = WARNING;
        }
        else if(PmProd.RequestedAutomaticAnticipation__c == 'Yes' && modeloDeAntecipacao == 'Antecipação Volume' && PmProd.RequestedAnticipationModelVolume__c <> null && PmProd.ApprovedAnticipationModelVolume__c == null) {
            debugMessage = 'O Modelo de Antecipação Automático (Volume) Solicitado não foi Aprovado por Risco. Ajuste o seu Product Pagar.me ou peça Aprovação de Risco.';
            resultType = WARNING;
        }
                
        // Validação Risco - Antecipação Spot            
        else if(modeloDeAntecipacao == 'Antecipação Spot' && PmProd.RequestedSpotAnticipationVolume__c <> null && (PmProd.RequestedSpotAnticipationVolume__c > PmProd.ApprovedSpotVolume__c)) {
            debugMessage = 'Você não pode Solicitar um Modelo de Antecipação Spot Maior do que o Aprovado por Risco. Ajuste o seu Product Pagar.me ou peça Aprovação de Risco.';
            resultType = WARNING;
        }
        else if(modeloDeAntecipacao == 'Antecipação Spot' && PmProd.RequestedSpotAnticipationVolume__c <> null && PmProd.ApprovedSpotVolume__c == null) {
            debugMessage = 'O Modelo de Antecipação Spot (Volume) Solicitado não foi Aprovado por Risco. Ajuste o seu Product Pagar.me ou peça Aprovação de Risco.';
            resultType = WARNING;
        }
        else if (temMDRzao == 'Yes' && PmProd.Dias_de_antecipacao__c == null){
            debugMessage = 'É necessário preencher o campo "Dias de antecipação".';
            resultType = WARNING;
        }
        else {

            // Valida se Status = 'Active'
            String respStatus;
            String Status;
            String segmentoAtual;
            map<String, Object> jsonRespStatus = new map<String,Object>();
            if(companyId <> null) {
                respStatus = stApiPagarme.MaisInfoPagarme(u.Email, companyId, cnpj);
                system.debug('respStatus-------- ' + respStatus);
                jsonRespStatus = (Map<String, Object>) System.JSON.deserializeUntyped(respStatus);
                Status = (String) jsonRespStatus.get('status');
            	segmentoAtual = (String) jsonRespStatus.get('antifraud_segment');
                
            }
            setupPagarmeProd(PagarmeProd.Id);
            
            // Configuração de Garantia proibida para renegs
            JsonAntifraudSeg = '\n' + '"antifraud_segment": "' + segmentoPagarme + '", ';
            if(Status == 'active' && (fraudCoveredFee != null || fraudCoveredFee != 0) && PmProd.Tem_garantia_de_chargeback__c == 'Sim') {
                if (segmentoAtual != segmentoPagarme){
                    JsonAntifraudSeg = '\n' + '"antifraud_segment": "' + segmentoPagarme + '", ';
                }
                else {
                    JsonAntifraudSeg = '';
                }
            }
            if(Status == 'active' && liberou == false && oppt.RecordType.Name != 'Upsell' && oppt.RecordType.Name != 'Churn Reversion') {
                debugMessage = 'Esse cliente já está ativo ! Será preciso pedir alteração de taxas para o RT ou clique no botão "Aprovação de taxas" caso seja um cliente que entrou por autocred !';
                resultType = WARNING;
            }
            else if (Status == 'active' && liberou == false && (oppt.RecordType.Name == 'Upsell' || oppt.RecordType.Name == 'Churn Reversion')) {
                debugMessage = 'É necessário ter um Pricing Aprovado para enviar !';
                resultType = WARNING;                
            }
            else {
                debugMessage = 'Ocorreu um erro. Fale com o administrador do sistema.';
                resultType = ERROR;
            }

            if (temMdrzao == 'Yes') {
                
                system.debug('anticipation_fee '+mdrzaoParcelas);
                system.debug(' anticipation_delay '+diasAntecipacaoMDRzao);
                system.debug('mdr'+ mdrzaoAVista);
                
                
                body = '{'
                	+ '\n' + '"gateway_fee": {'
                    	+ '\n' + '"credit_card": ' + gatewayFee + ', '
                    	+ '\n' + '"debit_card": ' + debitFee + ', '
                    	+ '\n' + '"boleto": ' + boletoEmitidoFee + ', '
                    	+ '\n' + '"pix": ' + pixGeradoFee
                	+ '\n' + '},'
                	+ '\n' + '"spread_fee": {'
                		+ '\n' + '"boleto": ' + boletoEmitidoPerc + ', '
                    	+ '\n' + '"pix": ' + pixGeradoPerc
                	+ '\n' + '},'
                	+ '\n' + '"paid_boleto": {'
                		+ '\n' + '"payment_fixed_fee": ' + boletoPagoFee + ', '
                		+ '\n' + '"payment_spread_fee": ' + boletoPagoPerc
                	+ '\n' + '},'
                    + '\n' + '"pix": {' // PIX Pago
                		+ '\n' + '"payment_fixed_fee": ' + pixPagoFee + ', '
                		+ '\n' + '"payment_spread_fee": ' + pixPagoPerc
                	+ '\n' + '},'
                    + '\n' + JsonGarantia
                    + '\n' + JsonAntifraudSeg
                    + '\n' + '"transfer_fee": ' + transferFee + ', '
                    + '\n' + '"antifraud_enabled": "' + antifraudeEnabled + '", '
                	+ '\n' + '"antifraud_cost": ' + antifraudeFee + ', '
                    + '\n' + '"anticipation_fee": ' + mdrzaoParcelas + ', ' 
                    + '\n' + '"anticipation_delay": ' + diasAntecipacaoMDRzao + ', '                      
                	+ '\n' + '"mdrs": [{'
                    	+ '\n' + '"capture_method": "ecommerce",'
                    	+ '\n' + '"payment_method": "credit_card", '
                    	+ '\n' + '"card_brand": ' + null + ', '
                		+ '\n' + '"installments": [{ '
                    		+ '\n' + '"installment": 1, '
                			+ '\n' + '"mdr": ' + mdrzaoAVista
                    	+ '\n' + '}]' 
                    + '\n' + '}], '
                	+ '\n' + '"payment_method": {'
                    	+ '\n' + '"boleto": ' + boletoEnabled + ', ' 
                    	+ '\n' + '"credit_card": ' + gatewayEnabled + ', '
                    	+ '\n' + '"pix": ' + pixEnabled
                    + '\n' + '},'
                	+ '\n' + '"mcc": "' + mcc + '", '
            		+ '\n' + '"api_version": "' + versaoAPI + '", '
                	+ '\n' + '"bill_name": "' + billName + '",'
                	+ '\n' + '"mdrzao": true'
                    + '\n' + '}';
                
            }
            else if (temMdrzao == 'No' || temMdrzao == '' || temMdrzao == null) {
            
                body = '{'
                	+ '\n' + '"gateway_fee": {'
                    	+ '\n' + '"credit_card": ' + gatewayFee + ', '
                    	+ '\n' + '"debit_card": ' + debitFee + ', '
                    	+ '\n' + '"boleto": ' + boletoEmitidoFee + ', '
                    	+ '\n' + '"pix": ' + pixGeradoFee
                    + '\n' + '},'
                	+ '\n' + '"spread_fee": {'
                		+ '\n' + '"boleto": ' + boletoEmitidoPerc + ', '
                    	+ '\n' + '"pix": ' + pixGeradoPerc
                    + '\n' + '},'
                	+ '\n' + '"paid_boleto": {'
                		+ '\n' + '"payment_fixed_fee": ' + boletoPagoFee + ', '
                		+ '\n' + '"payment_spread_fee": ' + boletoPagoPerc
                	+ '\n' + '},'
                    + '\n' + '"pix": {' // PIX Pago
                		+ '\n' + '"payment_fixed_fee": ' + pixPagoFee + ', '
                		+ '\n' + '"payment_spread_fee": ' + pixPagoPerc
                	+ '\n' + '},'
                    + '\n' + JsonGarantia
                    + '\n' + JsonAntifraudSeg
                    + '\n' + '"transfer_fee": ' + transferFee + ', '
                    + '\n' + '"antifraud_enabled": "' + antifraudeEnabled + '", '
                	+ '\n' + '"antifraud_cost": ' + antifraudeFee + ', '
                	+ '\n' + '"anticipation_fee": ' + anticipationFee + ', '
                	+ '\n' + anticipationType
                	+ '\n' + '"mdrs": [{'
                    	+ '\n' + '"capture_method": "ecommerce",'
                    	+ '\n' + '"payment_method": "credit_card", '
                    	+ '\n' + '"card_brand": "visa", '
                		+ '\n' + '"installments": [{ '
                    		+ '\n' + '"installment": 1, '
                			+ '\n' + '"mdr": ' + mdr1x
                		+ '\n' + '}, '
                		+ '\n' + '{ '
                    		+ '\n' + '"installment": 2, '
                			+ '\n' + '"mdr": ' + mdr2x6x
                		+ '\n' + '}, '
                		+ '\n' + '{ '
                    		+ '\n' + '"installment": 7, '
                			+ '\n' + '"mdr": ' + mdr7x12x
                		+ '\n' + '}]}, '
                		+ '\n' + '{ '
                			+ '\n' + '"capture_method": "ecommerce",'
                    		+ '\n' + '"payment_method": "credit_card", '
                    		+ '\n' + '"card_brand": "mastercard", '
                		+ '\n' + '"installments": [{ '
                    		+ '\n' + '"installment": 1, '
                			+ '\n' + '"mdr": ' + mdr1x
                		+ '\n' + '}, '
                		+ '\n' + '{ '
                    		+ '\n' + '"installment": 2, '
                			+ '\n' + '"mdr": ' + mdr2x6x
                		+ '\n' + '}, '
                		+ '\n' + '{ '
                    		+ '\n' + '"installment": 7, '
                			+ '\n' + '"mdr": ' + mdr7x12x
                		+ '\n' + '}]}, '
                		+ '\n' + '{ '
                			+ '\n' + '"capture_method": "ecommerce",'
                    		+ '\n' + '"payment_method": "credit_card", '
                    		+ '\n' + '"card_brand": "elo", '
                			+ '\n' + '"installments": [{ '
                    			+ '\n' + '"installment": 1, '
                				+ '\n' + '"mdr": ' + mdr1xOtherBrands
                			+ '\n' + '}, '
                			+ '\n' + '{ '
                    			+ '\n' + '"installment": 2, '
                				+ '\n' + '"mdr": ' + mdr2x6xOtherBrands
                			+ '\n' + '}, '
                			+ '\n' + '{ '
                    			+ '\n' + '"installment": 7, '
                				+ '\n' + '"mdr": ' + mdr7x12xOtherBrands
                    	+ '\n' + '}]}, '
                		+ '\n' + '{ '
                			+ '\n' + '"capture_method": "ecommerce",'
                    		+ '\n' + '"payment_method": "credit_card", '
                    		+ '\n' + '"card_brand": "hipercard", '
                			+ '\n' + '"installments": [{ '
                    			+ '\n' + '"installment": 1, '
                				+ '\n' + '"mdr": ' + mdr1xOtherBrands
                			+ '\n' + '}, '
                			+ '\n' + '{ '
                    			+ '\n' + '"installment": 2, '
                				+ '\n' + '"mdr": ' + mdr2x6xOtherBrands
                			+ '\n' + '}, '
                			+ '\n' + '{ '
                    			+ '\n' + '"installment": 7, '
                				+ '\n' + '"mdr": ' + mdr7x12xOtherBrands
                    	+ '\n' + '}]}, '
                		+ '\n' + '{ '
                			+ '\n' + '"capture_method": "ecommerce",'
                    		+ '\n' + '"payment_method": "credit_card", '
                    		+ '\n' + '"card_brand": "amex", '
                			+ '\n' + '"installments": [{ '
                    			+ '\n' + '"installment": 1, '
                				+ '\n' + '"mdr": ' + mdr1xOtherBrands
                			+ '\n' + '}, '
                			+ '\n' + '{ '
                    			+ '\n' + '"installment": 2, '
                				+ '\n' + '"mdr": ' + mdr2x6xOtherBrands
                			+ '\n' + '}, '
                			+ '\n' + '{ '
                    			+ '\n' + '"installment": 7, '
                				+ '\n' + '"mdr": ' + mdr7x12xOtherBrands
                    	+ '\n' + '}]}, '
                		+ '\n' + '{ '
                			+ '\n' + '"capture_method": "ecommerce",'
                    		+ '\n' + '"payment_method": "credit_card", '
                    		+ '\n' + '"card_brand": "diners", '
                			+ '\n' + '"installments": [{ '
                    			+ '\n' + '"installment": 1, '
                				+ '\n' + '"mdr": ' + mdr1xOtherBrands
                			+ '\n' + '}, '
                			+ '\n' + '{ '
                    			+ '\n' + '"installment": 2, '
                				+ '\n' + '"mdr": ' + mdr2x6xOtherBrands
                			+ '\n' + '}, '
                			+ '\n' + '{ '
                    			+ '\n' + '"installment": 7, '
                				+ '\n' + '"mdr": ' + mdr7x12xOtherBrands
                		+ '\n' + '}]}, '
                		+ '\n' + '{ '
                			+ '\n' + '"capture_method": "ecommerce",'
                    		+ '\n' + '"payment_method": "credit_card", '
                    		+ '\n' + '"card_brand": "jcb", '
                			+ '\n' + '"installments": [{ '
                    			+ '\n' + '"installment": 1, '
                				+ '\n' + '"mdr": ' + mdr1xOtherBrands
                			+ '\n' + '}, '
                			+ '\n' + '{ '
                    			+ '\n' + '"installment": 2, '
                				+ '\n' + '"mdr": ' + mdr2x6xOtherBrands
                			+ '\n' + '}, '
                			+ '\n' + '{ '
                    			+ '\n' + '"installment": 7, '
                				+ '\n' + '"mdr": ' + mdr7x12xOtherBrands
                    	+ '\n' + '}]' 
                    + '\n' + '}], '
                	+ '\n' + '"payment_method": {'
                    	+ '\n' + '"boleto": ' + boletoEnabled + ', '
                    	+ '\n' + '"credit_card": ' + gatewayEnabled + ', '
                    	+ '\n' + '"pix": ' + pixEnabled
                	+ '\n' + '},'
                	+ '\n' + '"mcc": "' + mcc + '", '
            		+ '\n' + '"api_version": "' + versaoAPI + '", '
                	+ '\n' + '"bill_name": "' + billName + '",'
                    + '\n' + '"mdrzinho": true'
                    + '\n' + '}';

            }
            
            try {
                
                String respPorcentagem = stApiPagarme.PorcentagemDashPagarme(u.Email, companyId, cnpj);
                Map<String, Object> JsonRespPorcentagem = (Map<String, Object>) System.JSON.deserializeUntyped(respPorcentagem);
                PorcentagemDash = (Decimal) JsonRespPorcentagem.get('percentage');
                
                if(respPorcentagem.contains('100')) {               
                    
                    String respProdutos = stApiPagarme.ProdutosDashPagarme(u.Email, companyId, cnpj, body);
                    Map<String, Object> jsonResp = (Map<String, Object>) System.JSON.deserializeUntyped(respProdutos);
                    
                    system.debug('resposta: ' + respProdutos);
                    
                    if (respProdutos.contains('Success')) {
                        debugMessage = 'Cadastrado com Sucesso !';
                        resultType = SUCCESS;
                        
                        PmProd.Enviou_Taxas_Comercial__c = true;
                        update PmProd;
                    }
                    else if (respProdutos.contains('Não há company_id nos headers')) {
                        debugMessage = 'Cadastro sem company_id !';
                        resultType = ERROR;
                    }
                    else if (respProdutos.contains('Ocorreu algum erro em nosso servidor')) {
                        debugMessage = 'Erro no servidor ! Tente novamente.';
                        resultType = ERROR;
                    }
                    else if (segmentoAtual != segmentoPagarme) {
                        debugMessage = 'Não é possível alterar o segmento de um cliente que já possua garantia de Chargeback ativada.';
                        resultType = ERROR;
                    }
                    else {
                        debugMessage = 'Erro no Cadastro !';
                        resultType = ERROR;
                    }
                }
                else {
                    debugMessage = 'Antes de prosseguir solicite que o cliente acesse à dash e finalize todas as pendências. Em seguida tente confirmar as taxas novamente.!';
                    resultType = ERROR;
                }
                
            } catch(Exception ex) {
            }
        }
        
        system.debug(PmProd.Preco_MDRzao__c);
        system.debug(PmProd.Dias_de_antecipacao__c);
        system.debug(PmProd.ApprovedAnticipationModelDays__c);                                                                                 
                                                                                            
        return null;
    }
}