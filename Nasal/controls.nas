var AP_Lmode=props.globals.initNode("autopilot/locks/heading","");
var AP_Larmed=props.globals.initNode("autopilot/locks/heading-armed","");
var AP_Vmode=props.globals.initNode("autopilot/locks/altitude","");
var AP_Varmed=props.globals.initNode("autopilot/locks/altitude-armed","");
var AP_status=props.globals.initNode("autopilot/locks/ap-status","");
var GSneedle=props.globals.initNode("instrumentation/nav/gs-needle-deflection");
var HDneedle=props.globals.initNode("instrumentation/nav/heading-needle-deflection-norm");
var Signal=props.globals.initNode("instrumentation/nav/signal-quality-norm");
var GSrange=props.globals.initNode("instrumentation/nav/gs-in-range");

setlistener("/sim/signals/fdm-initialized", func {
    settimer(update_systems,2);
});

setlistener("/sim/signals/reinit", func {
},0,0);


var set_ap_mode = func(md){
    if(md=="hdg"){
        var txt=AP_Lmode.getValue();
        if(txt!="HDG")txt="HDG" else {txt="";set_roll();}
        AP_Lmode.setValue(txt);
        AP_Larmed.setValue("");
    }elsif(md=="nav"){
        var txt=AP_Larmed.getValue();
        var txt2 ="VOR";
        if(getprop("instrumentation/nav/nav-loc"))txt2="LOC";
        if(txt2==txt){
            txt2="";set_roll();
        }else AP_Lmode.setValue("HDG");
        AP_Larmed.setValue(txt2);
    }elsif(md=="apr"){
        var txt=AP_Lmode.getValue();
        if(txt=="LOC"){
            AP_Varmed.setValue("GS");
        }
    }elsif(md=="bc"){
        var bcbtn=getprop("instrumentation/nav/back-course-btn");
        if(getprop("instrumentation/nav/nav-loc")){
            bcbtn=1-bcbtn;
        }else bcbtn=0;
        setprop("instrumentation/nav/back-course-btn",0);
    }elsif(md=="alt"){
        var txt=AP_Vmode.getValue();
        if(txt!="ALT"){
            txt="ALT";
            setprop("autopilot/settings/target-fl",(getprop("instrumentation/altimeter/indicated-altitude-ft")*0.01));
        } else {txt="";set_pitch();}
        AP_Vmode.setValue(txt);
        AP_Varmed.setValue("");
    }elsif(md=="asel"){
        var txt=AP_Varmed.getValue();
        if(txt!="ALT")txt="ALT" else txt="";
        AP_Varmed.setValue(txt);
    }elsif(md=="vs"){
        var txt=AP_Vmode.getValue();
        if(txt!="VS"){
            txt="VS";
            var fpm=getprop("autopilot/internal/vert-speed-fpm");
            fpm=(fpm*0.01)*100;
            setprop("autopilot/settings/target-vs",fpm);
        } else txt="";
        AP_Vmode.setValue(txt);
        AP_Varmed.setValue("");
    }elsif(md=="ias"){
        var txt=AP_Vmode.getValue();
        if(txt!="IAS")txt="IAS" else {txt="";set_pitch();}
        AP_Vmode.setValue(txt);
        AP_Varmed.setValue("");
    }elsif(md=="ap"){
        var txt=getprop("autopilot/locks/ap-status");
        if(txt!="AP"){
            txt="AP";
            if(AP_Lmode.getValue()=="")set_roll();
            if(AP_Vmode.getValue()=="")set_pitch();
        } else txt="";
        setprop("autopilot/locks/ap-status",txt);
    }
}

var set_pitch = func{
    setprop("autopilot/settings/target-pitch-deg",getprop("orientation/pitch-deg"));
}

var set_roll = func{
    setprop("autopilot/settings/target-roll-deg",getprop("orientation/roll-deg"));
}



var fd_pitch_wheel = func(dir){
    var txt =AP_Vmode.getValue();
        var val=getprop("autopilot/settings/target-vs");
    if(txt=="VS"){
        val+=(dir*100);
        if(val<-2000)val=-200;
        if(val>3000)val=3000;
        setprop("autopilot/settings/target-vs",val)
    }else{
        
    }
}

var check_armed = func{
    var lx=AP_Larmed.getValue();
    var vx=AP_Varmed.getValue();
    var sg=Signal.getValue();
    if(lx!=""){
        if(sg > 0.98){
        var ly=HDneedle.getValue();
            if(ly < 0.9 and ly > -0.9){
                AP_Lmode.setValue(AP_Larmed.getValue());
                AP_Larmed.setValue("");
            }
        }
    }
    if(vx=="GS"){
        if(GSrange.getValue()){
            if(AP_Lmode.getValue()=="LOC"){
                var gx=GSneedle.getValue();
                if(gx<0.5 and gx>-0.5){
                    AP_Vmode.setValue(AP_Varmed.getValue());
                    AP_Varmed.setValue("");
                }
            }
        }
        
    }elsif(vx=="ALT"){
    
    }
}

var update_systems = func{
    check_armed();
settimer(update_systems,0);
}