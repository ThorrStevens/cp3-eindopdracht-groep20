package splitr.model.services {

import flash.events.Event;
import flash.events.EventDispatcher;

import splitr.model.AppModel;

public class CalculatorService extends EventDispatcher{
    public static const NEW_TOTAL:String = "NEW_TOTAL";
    public static const REFRESH_LIST:String = "REFRESH_LIST";
    public static const SLIDERS_RECALCULATED:String = "SLIDERS_RECALCULATED";

    private var _appModel:AppModel;
    private var _shareList:Array;
    private var _sliderRestValue:Number;

    private static var instance:CalculatorService;

    public static function getInstance():CalculatorService {
        if (instance == null) {
            instance = new CalculatorService(new Enforcer());
        }
        return instance;
    }

    public function CalculatorService(e:Enforcer) {
        if (e == null) {
            throw new Error("CalculatorService is a singleton, use getInstance() instead");
        }

        _appModel = AppModel.getInstance();
    }

    public function methodByPage():void {
        switch(_appModel.currentPage) {
            case "EqualSplit":
                    equalSplit();
                break;
            case "PercentualSplit":
                    percentualSplit();
                break;
            case "AbsoluteSplit":
                    absoluteSplit();
                break;
        }
    }

    private function equalSplit():void {
        _shareList = new Array();
        var share:Number = Number((_appModel.bills[_appModel.currentBill].billTotal / _appModel.bills[_appModel.currentBill].billGroup.length).toFixed(2).toString());
        var i:uint = 0;
        _sliderRestValue = 100;
        while (i < _appModel.bills[_appModel.currentBill].billGroup.length){
            _shareList.push(share);
            _sliderRestValue -= share;
            trace("[Calc]", "SliderRestValue Eq:", _sliderRestValue);
            i++;
        }
    }

    private function percentualSplit():void {
        _shareList = new Array();
        var i:uint = 0;
        while (i < _appModel.bills[_appModel.currentBill].billGroup.length){
            _shareList[i] = _appModel.bills[_appModel.currentBill].billGroup[i].personShare;
            i++;
        }
    }

    private function absoluteSplit():void {
        _shareList = new Array();
        var i:uint = 0;
        while (i < _appModel.bills[_appModel.currentBill].billGroup.length){
            _shareList.push(_appModel.bills[_appModel.currentBill].billGroup[i].personShare);
            i++;
        }
    }

    public function get shareList():Array {
        return _shareList;
    }

    //RECALC

    public function recalculateByPage(newNum:Number, id):void {
        switch(_appModel.currentPage) {
            case "EqualSplit":
                //equalRecal();
                break;
            case "PercentualSplit":
                percentualRecal(newNum, id);
                break;
            case "AbsoluteSplit":
                absoluteRecal(newNum, id);
                break;
        }
    }

    private function percentualRecal(newNum:Number, id:uint):void {
        newNum = Number(newNum.toFixed(2).toString());

        _appModel.bills[_appModel.currentBill].billGroup[id].personShare = newNum;

        checkRestValue(id);

        for(var i:uint = 0; i < _appModel.bills[_appModel.currentBill].billGroup.length; i++){
            if(i != id && _appModel.bills[_appModel.currentBill].billGroup[i].personShare >= 0.00){
                _appModel.bills[_appModel.currentBill].billGroup[i].personShare = _appModel.bills[_appModel.currentBill].billGroup[i].personShare + (_sliderRestValue / (_appModel.bills[_appModel.currentBill].billGroup.length - 1));
            }
        }

        dispatchEvent(new Event("SLIDERS_RECALCULATED"));
    }

    private function checkRestValue(id:uint):void{
        _sliderRestValue = 100 - _appModel.bills[_appModel.currentBill].billGroup[id].personShare;
        for(var i:uint = 0; i < _appModel.bills[_appModel.currentBill].billGroup.length; i++){
            if(i != id){
                _sliderRestValue -= _appModel.bills[_appModel.currentBill].billGroup[i].personShare;
            }
        }
    }

    private function absoluteRecal(newNum:Number, id):void {
        _appModel.bills[_appModel.currentBill].billTotal =  _appModel.bills[_appModel.currentBill].billTotal  - _appModel.bills[_appModel.currentBill].billGroup[id].personShare;
        _appModel.bills[_appModel.currentBill].billTotal += newNum;
        _appModel.bills[_appModel.currentBill].billGroup[id].personShare = newNum;
        _appModel.save();

        newAbsolutTotal();
    }

    public function newAbsolutTotal():void {
        dispatchEvent(new Event("NEW_TOTAL"));
    }

    public function refreshList():void {
        dispatchEvent(new Event("REFRESH_LIST"));
    }

    public function get sliderRestValue():Number {
        return _sliderRestValue;
    }
}
}
internal class Enforcer{}