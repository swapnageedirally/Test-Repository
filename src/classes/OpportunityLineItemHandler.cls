public class OpportunityLineItemHandler {
    
    public static void isAfterInsert(OpportunityLineItem[] olis) {
        Map<id, List<Product_Package__c>> prodMap = new Map<id, List<Product_Package__c>>();
        Map<id, Map<id,PricebookEntry>> priceMap = new Map<id, Map<id,PricebookEntry>>();
        Map<id,id> pbeToPriceBookMap = new Map<id,id>();
        List<id> productIds = new List<id>();
        List<id> pbeIds = new List<id>();
        List<OpportunityLineItem> newOlis = new List<OpportunityLineItem>();

        //get Pricebookentry id because we need to get PriceBook info
        for(OpportunityLineItem oli : olis){
            productIds.add(oli.product2id);
            pbeIds.add(oli.pricebookentryid);
        }

        //loop through product packages and see if we have any work to do, if not we just womp out of this thing
        for(Product_Package__c pp : [select id, Parent_Product__c, Child_Product__c, quantity__c, Applicable_Account_Types__c,Optional_Pricing__c, Optional_Price__c from Product_Package__c
                                    WHERE Parent_Product__c IN : productIds AND Package_Options__c = 'Included']){
                if(prodMap.isEmpty())
                    prodMap.put(pp.Parent_Product__c, new List<Product_Package__c>{pp});
                else
                    prodMap.get(pp.Parent_Product__c).add(pp);
        }
        
        if(prodmap != null && !prodMap.isEmpty()){

            //get price book id which is not available through a formula field for some reason
            for(PricebookEntry pbe : [select id,isactive,Pricebook2Id,unitprice from PricebookEntry where ID IN : pbeIds]){
                pbeToPriceBookMap.put(pbe.id, pbe.Pricebook2Id);
            }
            
            //find the rest of the pricebook entries in the parent item's pricebook and bind them to the pricebook id in that fun map below
            for(PricebookEntry pb2 : [select id,isactive,product2id,unitprice,Pricebook2Id,product2.description,product2.sales_notes__c,product2.Product_Type__c from PricebookEntry where Pricebook2Id IN : pbeToPriceBookMap.values() AND isActive = true]){
                if(priceMap.isEmpty() || !priceMap.containsKey(pb2.Pricebook2Id))
                    priceMap.put(pb2.Pricebook2Id, new Map<id, Pricebookentry>{pb2.Product2id => pb2});
                else
                    priceMap.get(pb2.Pricebook2Id).put(pb2.Product2id, pb2);
            }

            for(OpportunityLineItem oli : [select id,
                                                  Product2id,
                                                  Opportunity_Account_Type__c,
                                                  opportunityid,
                                                  pricebookentryid,
                                                  opportunity.Total_Covered_Members__c,
                                                  opportunity.Total_Covered_Employees__c
                                                  from OpportunityLineItem WHERE ID IN : olis]){
                if(prodMap.containsKey(oli.Product2id)){
                    for(Product_Package__c pp2 : prodMap.get(oli.Product2id)){
                        if(pp2.Applicable_Account_Types__c == null || pp2.Applicable_Account_Types__c == '' || (pp2.Applicable_Account_Types__c != null && pp2.Applicable_Account_Types__c != '' && pp2.Applicable_Account_Types__c.contains(oli.Opportunity_Account_Type__c))){
                            OpportunityLineItem oliNew = new OpportunityLineItem();
                            oliNew.opportunityid = oli.opportunityid;
                            oliNew.quantity = pp2.quantity__c;
                            if(!pbeToPriceBookMap.isEmpty() && 
                                !priceMap.isEmpty() &&
                                    priceMap.get(pbeToPriceBookMap.get(oli.pricebookentryid)).containsKey(pp2.Child_Product__c)
                                        && priceMap.get(pbeToPriceBookMap.get(oli.pricebookentryid)).get(pp2.Child_Product__c).product2.Product_Type__c == 'Feature'){
                                oliNew.pricebookentryid = priceMap.get(pbeToPriceBookMap.get(oli.pricebookentryid)).get(pp2.Child_Product__c).id;
                                system.debug('DO WE GET THE PRICE INFO ' + priceMap.get(pbeToPriceBookMap.get(oli.pricebookentryid)).get(pp2.Child_Product__c).unitprice);
                                system.debug('DO WE GET THE PRICE INFO ' + pp2.quantity__c);
                                
                                oliNew.totalprice = priceMap.get(pbeToPriceBookMap.get(oli.pricebookentryid)).get(pp2.Child_Product__c).unitprice * pp2.quantity__c;
                                
                                /*if(pp2.Optional_Pricing__c != 'N/A'){
                                    if(pp2.Optional_Pricing__c == 'Flat')
                                        oliNew.totalprice = pp2.Optional_Price__c;
                                    else if(pp2.Optional_Pricing__c == 'PMPM' && oli.opportunity.Total_Covered_Members__c != null)
                                        oliNew.totalprice = pp2.Optional_Price__c * oli.opportunity.Total_Covered_Members__c;
                                    else if(pp2.Optional_Pricing__c == 'PEPM' && oli.opportunity.Total_Covered_Employees__c != null)
                                        oliNew.totalprice =  pp2.Optional_Price__c * oli.opportunity.Total_Covered_Employees__c;
                                }*/

                                system.debug('DO WE GET THE TOTAL PRICE ' + oliNew.totalprice);
                                oliNew.Parent_Opportunity_Product_ID__c = oli.id;
                                oliNew.Opportunity_Product_Type__c = priceMap.get(pbeToPriceBookMap.get(oli.pricebookentryid)).get(pp2.Child_Product__c).product2.Product_Type__c;
                                newOlis.add(olinew);
                            }
                            else{
                                //oli.addError('Missing Pricing Info - Contact System Administration');
                            }
                        }
                    }
                }
            }

            if(!newOlis.isEmpty())
                insert newOlis;
        }
    }

    public static void beforeDelete(OpportunityLineItem[] olis){
            
        system.debug('DO WE GET BEFORE DELELTE ' + olis);

        List<string> packs = new List<string>();

        for(OpportunityLineItem oli : olis){
            if(oli.Product_Type_Formula__c == 'Package'){
                packs.add(oli.id);
            }   
        }

        system.debug('DO WE HAVE PACKAGES FOR DELELTE ' + packs);

        if(!packs.isEmpty()){
            List<OpportunityLineItem> delOlis = [select id from OpportunityLineItem where Parent_Opportunity_Product_ID__c IN : packs AND ID NOT IN : olis];

            system.debug('DO WE HAVE DELETE SUB OLIS ' + delOlis);

            if(!delOlis.isEmpty())
                delete delOlis;
        }
    }

    public static void beforeInsert(OpportunityLineItem[] olis){

        /*system.debug('DO WE GET BEFORE INSERT ' + olis);

        Map<id, Product_Package__c> ppMap = new Map<id,Product_Package__c>();
        Map<OpportunityLineItem, id> upsellParent = new Map<OpportunityLineItem,id>();
        map<id, OpportunityLineItem> upsells = new map<id, OpportunityLineItem>();
        set<id> oppyIDs = new set<id>();
        String defaultVals = '';

        for(OpportunityLineItem oli : olis){
            if(oli.Product_Type_Formula__c == 'Feature' && oli.product_sub_type_formula__c == 'Upsell Feature'){
                upsells.put(oli.id, oli);
                upsellParent.put(oli, oli.Parent_Opportunity_Product_ID__c);
                oppyIDs.add(oli.OpportunityId);
            }   
        }

        if(!upsells.isEmpty()){

            Map<id,Opportunity> oppyMap = new Map<id,opportunity>([select id, Total_Covered_Members__c,Total_Covered_Employees__c from Opportunity where ID IN : oppyIDs]);

            system.debug('DO WE HAVE UPSELL PRICING - ' + oppyMap);

            for(Product_Package__c pp1 : [select id,
                                                 Child_Product__c,
                                                 Parent_Product__c,
                                                 Optional_Pricing__c,
                                                 Optional_Price__c
                                                 from Product_Package__c WHERE
                                                 (Parent_Product__c IN : upsellParent.values() AND Child_Product__c IN : upsells.keyset())]){
                if(pp1.Optional_Pricing__c != null && (pp1.Optional_Pricing__c != '' && pp1.Optional_Pricing__c != 'N/A'))
                    ppMap.put(pp1.child_product__c, pp1);
            }
            
            system.debug('DO WE HAVE PACKAGE PRODS ' + ppMap);
        
            for(OpportunityLineItem oli: upsells.values()){
                if(ppMap != null && ppMap.containsKey(oli.id) && oli.Parent_Opportunity_Product_ID__c == ppMap.get(oli.id).Parent_Product__c){
                    if(ppMap.get(oli.id).Optional_Pricing__c != null && ppMap.get(oli.id).Optional_Pricing__c != 'N/A'){
                        if(ppMap.get(oli.id).Optional_Pricing__c == 'Flat')
                            oli.totalprice = ppMap.get(oli.id).Optional_Price__c;
                        else if(ppMap.get(oli.id).Optional_Pricing__c == 'PMPM' && oppyMap.get(oli.OpportunityId).Total_Covered_Employees__c != null)
                            oli.totalprice = ppMap.get(oli.id).Optional_Price__c * oppyMap.get(oli.OpportunityId).Total_Covered_Employees__c;
                        else if(ppMap.get(oli.id).Optional_Pricing__c == 'PEPM' && oppyMap.get(oli.OpportunityId).Total_Covered_Employees__c != null)
                            oli.totalprice =  ppMap.get(oli.id).Optional_Price__c * oppyMap.get(oli.OpportunityId).Total_Covered_Employees__c;
                    }
                }
            }
        }*/
    }

    public static void updateOLITotal(OpportunityLineItem[] olis, Map<id, OpportunityLineItem> oliMap) {
        Map<id,decimal> updateIds = new Map<Id, Decimal>();
        Map<id,id> pbeMap = new Map<Id, id>();
        List<OpportunityLineItem> upsertOlis = new List<OpportunityLineItem>();
        set<id> upsertOliIds = new set<id>();

        //Change to logic to look to Pricebook2 to find the appropriate PBE ID
        for(Pricebookentry pbe : [select id, Pricebook2Id from Pricebookentry where Product2.Product_Type__c = 'Implementation Fee']){
            pbeMap.put(pbe.Pricebook2Id ,pbe.id);
        }

        system.debug('pbeMap IS ' + pbeMap);
        if(!pbeMap.isEmpty() || test.isRunningTest()){
            for(OpportunityLineItem oli : [select id,Price_Book_ID__c, Implementation_Fee__c, name, opportunityid from OpportunityLineItem where ID IN :olis]){
                if((trigger.isInsert && oli.Implementation_Fee__c != null && oli.Implementation_Fee__c > 0) || (trigger.isUpdate && oli.Implementation_Fee__c != null && oli.Implementation_Fee__c > 0 && (oliMap.get(oli.id).Implementation_Fee__c == null || oliMap.get(oli.id).Implementation_Fee__c == 0))){
                    OpportunityLineItem oli1 = new OpportunityLineItem();
                    oli1.opportunityid = oli.opportunityid;
                    
                    //implement logic from Map here to find the correct implementation fee for this Pricebook, otherwise use backup
                    if(pbeMap.containsKey(oli.Price_Book_ID__c))
                        oli1.pricebookentryid = pbeMap.get(oli.Price_Book_ID__c);
                    else
                        oli1.pricebookentryid = label.DEFAULT_IMPLEMENTATION_FEE_PRODUCT_ID;
                    
                    oli1.quantity = 1;
                    oli1.unitprice = oli.Implementation_Fee__c;
                    oli1.description = 'Implementation Fee related to Opportunity Product ' + oli.name;
                    oli1.Parent_Opportunity_Product_ID__c = oli.id;
                    oli1.Opportunity_Product_Type__c = 'Implementation Fee';
                    upsertOlis.add(oli1);
                }
                else if(trigger.isUpdate && oli.Implementation_Fee__c != oliMap.get(oli.id).Implementation_Fee__c && oliMap.get(oli.id).Implementation_Fee__c != null && oliMap.get(oli.id).Implementation_Fee__c > 0){
                    updateIds.put(oli.id, oli.Implementation_Fee__c);
                    system.debug('WHAT IS THE NEW Implementation_Fee__c' + updateIds);
                }
            }

            if(!updateIds.isEmpty()){
                OpportunityLineItem[] olix = [select id, unitprice, Parent_Opportunity_Product_ID__c from OpportunityLineItem where Parent_Opportunity_Product_ID__c IN : updateIds.keyset() AND pricebookentry.product2.Product_Type__c = 'Implementation Fee'];
                
                system.debug('WHAT IS THE CHILD LINE' + olix);

                for(OpportunityLineItem ol : olix){
                    ol.unitprice = updateIds.get(ol.Parent_Opportunity_Product_ID__c);
                    upsertOlis.add(ol);
                    upsertOliIds.add(ol.id);
                }
            }

            if(!upsertOlis.isEmpty())   
                upsert upsertOlis;

            system.debug('UPSERTED FEES ARE ' + upsertOlis);
        }
    }
}