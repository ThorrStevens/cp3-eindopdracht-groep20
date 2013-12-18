package splitr.mobile.view.pages {

import feathers.controls.Button;
import feathers.controls.PanelScreen;
import feathers.controls.ScrollContainer;
import feathers.controls.ToggleSwitch;
import flash.events.Event;

import splitr.mobile.view.components.OverviewItem;
import splitr.model.AppModel;

import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;
import starling.utils.HAlign;

public class OverviewPage extends PanelScreen {

    private var _appModel:AppModel;

    private var _width:uint;
    private var _startDragX:Number;
    private var _startPanelX:Number;
    private var _bills:Array;

    private var _txtOverview:TextField;
    private var _listOption:ToggleSwitch;
    private var _billList:ScrollContainer;
    private var _newEqualSplitButton:Button;
    private var _newPercentualSplitButton:Button;
    private var _newAbsoluteSplitButton:Button;

    public function OverviewPage(w:uint = 480) {

        _appModel = AppModel.getInstance();

        // Set header title
        headerProperties.title = "SPLITR";
        _width = w;

        _appModel.addEventListener(AppModel.BILLS_CHANGED, billsChangedHandler);
        _appModel.load();

    }

    private function initPage():void{
        var message:String;
        if(_appModel.bills.length < 1){
            message = "No bills yet. Choose split method:";
        }else{
            message = "Drag right to edit, left to delete.";
        }

        _txtOverview = new TextField(400, 50, "0", "PF Ronda Seven", 19, 0xCCCCCC);
        _txtOverview.text = message;
        _txtOverview.hAlign = HAlign.CENTER;
        _txtOverview.x = _width/2 - _txtOverview.width/2;
        _txtOverview.y = 60;
        addChild(_txtOverview);

        _listOption = new ToggleSwitch();
        _listOption.width = 100;
        _listOption.x = _width/2 - 50;
        _listOption.y = 10;
        _listOption.isSelected = true;
        _listOption.addEventListener(starling.events.Event.CHANGE, optionHandler);
        if(_appModel.bills.length < 1){
            _listOption.isEnabled = false;
        }
        addChild(_listOption);

        createList();

        _newEqualSplitButton = new Button();
        _newEqualSplitButton.label = "+ Equal";
        _newEqualSplitButton.width = _width/3;
        _newEqualSplitButton.x = 0;
        _newEqualSplitButton.addEventListener(starling.events.Event.TRIGGERED, newEqualHandler);
        addChild(_newEqualSplitButton);

        _newPercentualSplitButton = new Button();
        _newPercentualSplitButton.label = "+ Percentual";
        _newPercentualSplitButton.width = _width/3;
        _newPercentualSplitButton.x = _width * 1/3;
        _newPercentualSplitButton.addEventListener(starling.events.Event.TRIGGERED, newPercentualHandler);
        addChild(_newPercentualSplitButton);

        _newAbsoluteSplitButton = new Button();
        _newAbsoluteSplitButton.label = "+ Absolute";
        _newAbsoluteSplitButton.width = _width/3;
        _newAbsoluteSplitButton.x = _width * 2/3;
        _newAbsoluteSplitButton.addEventListener(starling.events.Event.TRIGGERED, newAbsoluteHandler);
        addChild(_newAbsoluteSplitButton);

        _newEqualSplitButton.y = _newPercentualSplitButton.y = _newAbsoluteSplitButton.y = 681;
    }

    private function billsChangedHandler(e:flash.events.Event):void {
        initPage();
    }

    private function newEqualHandler(e:starling.events.Event):void {
        _appModel.createNewPage = true;
        _appModel.currentPage = "EqualSplit";
    }

    private function newPercentualHandler(e:starling.events.Event):void {
        _appModel.createNewPage = true;
        _appModel.currentPage = "PercentualSplit";
    }

    private function newAbsoluteHandler(e:starling.events.Event):void {
        _appModel.createNewPage = true;
        _appModel.currentPage = "AbsoluteSplit";
    }

    private function optionHandler(e:starling.events.Event):void {
        if(_listOption.isSelected == true){
            createList("Settled");
        }else{
            createList("Unsettled");
        }
    }

    private function createList(billsToShow:String = "All"):void {
        trace("[Overview]", "Bills:", _appModel.bills);

        if(_billList){
            removeChild(_billList);
        }

        _billList = new ScrollContainer();
        addChild(_billList);

        _billList.width = 480;
        _billList.height = 540;
        _billList.y = 116;

        _bills = new Array();


        _appModel.bills.reverse();
        for(var i:uint = 0; i < _appModel.bills.length; i++){
            var overviewItem:OverviewItem = new OverviewItem(_width);
            switch(billsToShow)
            {
                case "Settled":
                    if(_appModel.bills[i].settledState == true){
                        overviewItem.billVO = _appModel.bills[i];
                        _billList.addChild(overviewItem);
                        _bills.push(overviewItem);
                    }
                    break;
                case "Unsettled":
                    if(_appModel.bills[i].settledState == false){
                        overviewItem.billVO = _appModel.bills[i];
                        _billList.addChild(overviewItem);
                        _bills.push(overviewItem);
                    }
                    break;
                case "All":
                    overviewItem.billVO = _appModel.bills[i];
                    _billList.addChild(overviewItem);
                    _bills.push(overviewItem);
                    break;
            }

            overviewItem.addEventListener(TouchEvent.TOUCH, touchHandler);
            overviewItem.addEventListener(OverviewItem.EDIT_BILL, editBillHandler);
            overviewItem.addEventListener(OverviewItem.DELETE_BILL, deleteBillHandler);
            overviewItem.y = overviewItem.height * _bills.length - 50;
        }
        _appModel.bills.reverse();
    }

    private function deleteBillHandler(e:starling.events.Event):void {
        var bill:OverviewItem = e.currentTarget as OverviewItem;
        _appModel.bills.splice(bill.billVO.billId, 1);

        _appModel.setIds();
        createList();
    }

    private function editBillHandler(e:starling.events.Event):void {
        var bill:OverviewItem = e.currentTarget as OverviewItem;
        _appModel.currentBill = bill.billVO.billId;

        switch (_appModel.bills[_appModel.currentBill].billType){
            case "Equal":
                _appModel.currentPage = "EqualSplit";
                break;
            case "Percentual":
                _appModel.currentPage = "PercentualSplit";
                break;
            case "Absolute":
                _appModel.currentPage = "AbsoluteSplit";
                break;
        }
    }

    private function touchHandler(e:TouchEvent):void {
        var touchedObject:OverviewItem = e.currentTarget as OverviewItem;
        var elementsX:Number = new Number();
        var touch:Touch = e.getTouch(touchedObject);
        if(touch != null) {
            switch(touch.phase) {
                case TouchPhase.BEGAN:
                    _startDragX = touch.globalX;
                    _startPanelX = touchedObject.x;
                    break;
                case TouchPhase.MOVED:
                    var diffX:Number = touch.globalX - _startDragX;
                    elementsX = (_startPanelX + diffX)/5;
                    touchedObject.setElementsX(elementsX);
                    break;
                case TouchPhase.ENDED:
                    touchedObject.release();
                    break;
            }
        }
    }

}
}
