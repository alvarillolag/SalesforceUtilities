/*
*	Author:- Rahul Malhotra
*	Description:- Utility class to sort list of sObjects
*	Created Date:- 04-12-2021
*	Last Modified:- 24-11-2022
*   Code Origin:- SFDC Stop (https://www.sfdcstop.com)
*   
*   Modificado y ampliado por alvarillolag
*
*/

public with sharing class SortUtil implements Comparable {

    public enum SortOrder { ASCENDING, DESCENDING }
    public enum Type { TYPE_STRING, TYPE_INTEGER, TYPE_DECIMAL, TYPE_DATETIME, TYPE_DATE }

    sObject record;
    SortOrder sortOrderValue;
    String fieldName;
    Type valueType;

    public SortUtil(sObject record, SortOrder sortOrderValue, String fieldName, Type valueType) {
        this.record = record;
        this.sortOrderValue = sortOrderValue;
        this.fieldName = fieldName;
        this.valueType = valueType;
    }

    public Integer compareTo(Object anotherObject) {
        sObject anotherRecord = ((SortUtil) anotherObject).record;
        Integer result = -1;

        if(valueType.equals(Type.TYPE_STRING)) {
            result = compareStrings((String) record.get(fieldName), (String) anotherRecord.get(fieldName));
        } else if(valueType.equals(Type.TYPE_INTEGER)) {
            result = compareIntegers((Integer) record.get(fieldName), (Integer) anotherRecord.get(fieldName));
        } else if(valueType.equals(Type.TYPE_DECIMAL)) {
            result = compareDecimals((Decimal) record.get(fieldName), (Decimal) anotherRecord.get(fieldName));
        }else if(valueType.equals(Type.TYPE_DATE)){
            result = compareDates((Date) record.get(fieldName), (Date) anotherRecord.get(fieldName));
        }else if(valueType.equals(Type.TYPE_DATETIME)){
            result = compareDatetimes((Datetime) record.get(fieldName), (Datetime) anotherRecord.get(fieldName));
        }

        return result;
    }

    public Integer compareStrings(String sourceValue, String destinationValue) {
        Integer result;

        if(sortOrderValue.equals(SortOrder.ASCENDING)) {
            if(sourceValue < destinationValue) {
                result = -1;
            } else if(sourceValue.equals(destinationValue)) {
                result = 0;
            } else {
                result = 1;
            }
        } else {
            if(sourceValue < destinationValue) {
                result = 1;
            } else if(sourceValue.equals(destinationValue)) {
                result = 0;
            } else {
                result = -1;
            }
        }

        return result;
    }


    public Integer compareIntegers(Integer sourceValue, Integer destinationValue) {
        Integer result;
        if(sortOrderValue.equals(SortOrder.ASCENDING)) {
            if(sourceValue < destinationValue) {
                result = -1;
            } else if(sourceValue == destinationValue) {
                result = 0;
            } else {
                result = 1;
            }
        } else {
            if(sourceValue < destinationValue) {
                result = 1;
            } else if(sourceValue == destinationValue) {
                result = 0;
            } else {
                result = -1;
            }
        }
        return result;
    }

    public Integer compareDecimals(Decimal sourceValue, Decimal destinationValue) {
        Integer result;
        if(sortOrderValue.equals(SortOrder.ASCENDING)) {
            if(sourceValue < destinationValue) {
                result = -1;
            } else if(sourceValue == destinationValue) {
                result = 0;
            } else {
                result = 1;
            }
        } else {
            if(sourceValue < destinationValue) {
                result = 1;
            } else if(sourceValue == destinationValue) {
                result = 0;
            } else {
                result = -1;
            }
        }
        return result;
    }

    public Integer compareDatetimes(Datetime sourceValue, Datetime destinationValue) {
        Integer result;
        if(sortOrderValue.equals(SortOrder.ASCENDING)) {
            if(sourceValue < destinationValue) {
                result = -1;
            } else if(sourceValue == destinationValue) {
                result = 0;
            } else {
                result = 1;
            }
        } else {
            if(sourceValue < destinationValue) {
                result = 1;
            } else if(sourceValue == destinationValue) {
                result = 0;
            } else {
                result = -1;
            }
        }
        return result;
    }

    public Integer compareDates(Date sourceValue, Date destinationValue) {
        Integer result;
        if(sortOrderValue.equals(SortOrder.ASCENDING)) {
            if(sourceValue < destinationValue) {
                result = -1;
            } else if(sourceValue == destinationValue) {
                result = 0;
            } else {
                result = 1;
            }
        } else {
            if(sourceValue < destinationValue) {
                result = 1;
            } else if(sourceValue == destinationValue) {
                result = 0;
            } else {
                result = -1;
            }
        }
        return result;
    }

    public static void sortRecords(List<sObject> records, SortOrder sortOrderValue, String fieldName, Type valueType) {
        List<SortUtil> sortUtils = new List<SortUtil>();
        for(sObject record : records) {
            sortUtils.add(new SortUtil(record, sortOrderValue, fieldName, valueType));
        }
        sortUtils.sort();
        records.clear();
        for(SortUtil sortUtil : sortUtils) {
            records.add(sortUtil.record);
        }
    }
}