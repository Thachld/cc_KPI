public with sharing class cc_KPI_Calculation_Helper {

    public class SpendingWrapper{
        public String saleId;
        public String industry;
        public String agency;
        public Boolean isXaxis;
        public Boolean isXaxisOwner;
        public Boolean isSpecialclient;
        public Boolean isStrategicClient;
        public Boolean isHNRegion;        
        public Decimal Amount;        
    }

    public class PaymentWrapper{
        public String saleId;
        public String industry;
        public String agency;
        public Boolean isXaxis;
        public Boolean isXaxisOwner;
        public Boolean isSpecialclient;
        public Boolean isStrategicClient;
        public Boolean isHNRegion;        
        public Decimal Amount;        
    }

    public static cc_QCData_wraper getSupportSpendingKPICategory(User urs, SpendingWrapper spendingdata){
        cc_QCData_wraper qc  = new  cc_QCData_wraper();
        qc.Amount = spendingdata.Amount;
        qc.Industry =  spendingdata.industry;        
        qc.SpecialClient = spendingdata.isSpecialclient;
        qc.Xaxis = spendingdata.isXaxis;
        qc.Agency = spendingdata.agency;  
        String KPICat;
        
        if(urs !=null){
            if(urs.Sale_Team__c == 'Global Agency'){
                if(!String.isBlank(spendingdata.agency.trim())){
                    KPICat = spendingdata.agency.trim();
                }else {
                    KPICat = 'Blank Agency';
                }
                
            }else if(urs.Sale_Team__c == 'Local Agency'){
                if(!String.isBlank(spendingdata.agency.trim())){
                    KPICat = spendingdata.agency.trim();   
                }else{
                    KPICat = 'Blank Agency';
                }
                
            }else if(urs.Sale_Team__c == 'Direct'){
                if(!String.isBlank(spendingdata.industry)){
                    if(spendingdata.industry == 'Retails' 
                        || spendingdata.industry == 'FMCG'){
                        KPICat = 'FMCG-Retails';
                    }else{
                        KPICat = spendingdata.industry.trim();
                    }
                }else {
                    KPICat = 'Blank Industry';
                }    
            }else {
                KPICat = 'Blank Sale Team';
            }
        }else {
            KPICat = 'Sale does not Exists';
        }

        qc.KPICategory = KPICat;

        return qc;
    }

    public static cc_QCData_wraper getSupportPaymentKPICategory(User urs, PaymentWrapper paymentdata){
        cc_QCData_wraper qc  = new  cc_QCData_wraper();
        qc.Amount = paymentdata.Amount;
        qc.Industry =  paymentdata.industry;        
        qc.SpecialClient = paymentdata.isSpecialclient;
        qc.Xaxis = paymentdata.isXaxis;
        qc.Agency = paymentdata.agency;  
        String KPICat;
        
        if(urs !=null){
            if(urs.Sale_Team__c == 'Global Agency'){
                if(!String.isBlank(paymentdata.agency.trim())){
                    KPICat = paymentdata.agency.trim();
                }else {
                    KPICat = 'Blank Agency';
                }
                
            }else if(urs.Sale_Team__c == 'Local Agency'){
                if(!String.isBlank(paymentdata.agency.trim())){
                    KPICat = paymentdata.agency.trim();   
                }else{
                    KPICat = 'Blank Agency';
                }
                
            }else if(urs.Sale_Team__c == 'Direct'){
                if(!String.isBlank(paymentdata.industry)){
                    if(paymentdata.industry == 'Retails' 
                        || paymentdata.industry == 'FMCG'){
                        KPICat = 'FMCG-Retails';
                    }else{
                        KPICat = paymentdata.industry.trim();
                    }
                }else {
                    KPICat = 'Blank Industry';
                }    
            }else {
                KPICat = 'Blank Sale Team';
            }
        }else {
            KPICat = 'Sale does not Exists';
        }

        qc.KPICategory = KPICat;

        return qc;
    }
}
