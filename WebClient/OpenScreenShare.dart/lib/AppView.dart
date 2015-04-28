library AppView;

import 'dart:html';
import 'dart:async';

class AppView {
  Element baseElement;
  Element sessionInputElement;
  DivElement ScreenSpace;

  Map MyElements = new Map<String, Element>();
  
  AppView(Element baseElement, Element sessionInput) {
    this.baseElement = baseElement;
    this.sessionInputElement = sessionInput;
  }

  void buildTabView() {
    // Build a Tab Area or what ever you want
    MyElements['tabList'] = new Element.tag('ul')
     ..setAttribute('class', 'nav nav-tabs');

    MyElements['tabContent'] = new Element.tag('div')
     ..setAttribute('class', 'tab-content');
    
    ScreenSpace = new Element.tag('div')
     ..setAttribute('id', 'screenSpace')
     ..setAttribute('class', 'tabbable')
     ..children.add(MyElements['tabList']);

    baseElement.children.add(ScreenSpace);    
  }

  void addTabContent(String id, Element content) {
    MyElements['tabContent'].children.add( new Element.tag('div')
     ..setAttribute('class', 'tab-pane')
     ..setAttribute('id', id)
     ..children.add(content));
  }
  
  void sessionKeyFeedback(bool validkey) {
    if(validkey) {
      sessionInputElement.style.backgroundColor = '';
    } else {
      sessionInputElement.style.backgroundColor = 'red';
    }
  }

  void addSessionInputHandler(Function handler) {
    sessionInputElement.onKeyUp.listen((_) {
      String sessionkey = sessionInputElement.value;
      bool valid = handler(sessionkey);
      sessionKeyFeedback(valid);
    });
    sessionInputElement.onPaste.listen((_) {
      const ms = const Duration(milliseconds: 100);
      new Timer(ms, () { 
        String sessionkey = sessionInputElement.value;
        bool valid = handler(sessionkey);
        sessionKeyFeedback(valid);
      });
    });
  }

  DivElement getScreenSpaceArea() {
    return ScreenSpace;
  }
}