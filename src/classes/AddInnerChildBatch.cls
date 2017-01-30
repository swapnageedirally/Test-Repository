global class AddInnerChildBatch implements Database.batchable<OldNewId>,Database.Stateful{ 
    global List<OldNewId> recIdNewIdObj = new List<OldNewId>();
    
    
    global Iterable<OldNewId> start(Database.batchableContext info){ 
        IterateFillData fillData = new IterateFillData();
        fillData.sObjectList = recIdNewIdObj;
        return fillData; 
    }     
    global void execute(Database.batchableContext info, List<OldNewId> scope){ 
        OldNewId obj = scope[0];
        String parentObjAPIName=CloneCtrl.returnAPIObjectName(obj.oldId); 
        system.debug('batch parentObjAPIName' +parentObjAPIName);
        ChildFieldNameClass obj1 = CloneCtrl.getAllChildObjNames(parentObjAPIName,obj.oldId); 
        system.debug('batch ChildFieldNameClass' +obj1);
        Map<String,String> objLabelobjAPI = obj1.childFieldsName;
        system.debug('batch objLabelobjAPI' +objLabelobjAPI);
        Map<String,String> chidlObjAPIName_FieldAPIName  = obj1.chidlObjAPIName_FieldAPIName;
        system.debug('batch chidlObjAPIName_FieldAPIName' +chidlObjAPIName_FieldAPIName);
        Map<String, list<String>> objFields = CloneCtrl.getChildObjWithCreateableField(obj.oldId,objLabelobjAPI.values(),chidlObjAPIName_FieldAPIName);
        system.debug('batch objFields' +objFields);
        for(String childObjAPIName:objFields.keySet()) {
            CloneCtrl.cloneChildRecords(chidlObjAPIName_FieldAPIName,childObjAPIName,CloneCtrl.getCreatableFields(childObjAPIName),parentObjAPIName,obj.newId,obj.oldId);
        }
    }     
    global void finish(Database.batchableContext info){    
         
    } 
}