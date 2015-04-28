// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:OpenScreenShare/AppView.dart';
import 'package:OpenScreenShare/DataGetter.dart';
import 'package:OpenScreenShare/ScreenSpace.dart';
import 'package:OpenScreenShare/SessionManager.dart';


const String SERVICE_URL = 'http://127.0.0.1/colaboration';

void addCanvasTab() {
  
}

main() {
  // define a main working area
  Element mainarea = querySelector('#mainarea'); //  var mainview = new AppView(document.body);
  Element sessionInputElement = querySelector('#sessionkey');

  // add control elements of the app
  AppView mainview = new AppView(mainarea, sessionInputElement);
  mainview.buildTabView();

  // start a SessionManager
  SessionManager sessionM = new SessionManager(sessionInputElement);
  
  mainview.addSessionInputHandler((String skey) {
      bool valid = sessionM.checkSessionKey(skey);
      if(valid) {
        sessionM.addSessionKey(skey);
      }
      return valid;
    });


/*  
  // get the area where the screens will show 
  var canvasArea = mainview.getScreenSpaceArea();

  // canvas stuff
  var screenSpace = new ScreenSpace(900, 450);
  screenSpace.addNewCanvas('Testing', canvasArea);
  screenSpace.initContext();

  // network loader
  var getter = new DataGetter('http://127.0.0.1/colaboration/', 10);
  getter.getPicture();
  */
}

