
import { assert, log } from './Utils'

export function stringItem(name:string,value:string):ConfigItem{
    assert((name != null),'the name should not be null')
    assert((name != undefined),'the name should not be undefined')
    assert((value != null),'the value should not be null')
    assert((value != undefined),'the value should not be undefined')
  
    let item = new ConfigItem();
    item.name = name;
    item.value = value;
    item.type = ConfigItemType.String;
    return item;
  }
  
  export function numberItem(name:string,value:number):ConfigItem{

    assert((name != null),'the name should not be null')
    assert((name != undefined),'the name should not be undefined')
    assert((value != null),'the value should not be null')
    assert((value != undefined),'the value should not be undefined')

    let item = new ConfigItem();
    item.name = name;
    item.value = value;
    item.type = ConfigItemType.Number;
    return item;
  }
  
  export function booleanItem(name:string,value:boolean):ConfigItem{
    assert((name != null),'the name should not be null')
    assert((name != undefined),'the name should not be undefined')
    assert((value != null),'the value should not be null')
    assert((value != undefined),'the value should not be undefined')

    let item = new ConfigItem();
    item.name = name;
    item.value = value;
    item.type = ConfigItemType.Boolean;
    return item;
  }
  
  export function objectItem(name:string,value:Object):ConfigItem{

    assert((name != null),'the name should not be null')
    assert((name != undefined),'the name should not be undefined')
    assert((value != null),'the value should not be null')
    assert((value != undefined),'the value should not be undefined')

    const jsonString = JSON.stringify(value);
    log("objectItem, jsonString: " + jsonString);
  
    let item = new ConfigItem();
    item.name = name;
    item.value = jsonString;
    item.type = ConfigItemType.Json;
    return item;
  }



  export enum  ConfigItemType{
    Unknown = -1,
    String  = 1,
    Number  = 2,
    Boolean = 3,
    Json    = 4
  }

  export class ConfigItem{
  
     name:string|null = null;
     value:string|boolean|number|null = null;
     type:ConfigItemType = ConfigItemType.Unknown;
  }