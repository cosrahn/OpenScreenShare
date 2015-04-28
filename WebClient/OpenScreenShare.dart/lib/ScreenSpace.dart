library ScreenSpace;

import 'dart:html';

class ScreenSpace {
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;

  int width = 900,
      height = 450;

  ScreenSpace(int width, int height) {
    this.width = width;
    this.height = height;
  }

  void addNewCanvas(String id, Element node) {
    canvas = new Element.tag('canvas')
     ..setAttribute('id', id)
     ..width = 900
     ..height = 450;

    // document.body.nodes.add(canvas);
    node.children.add(canvas);
  }
  
  void initContext() {
    ctx = canvas.getContext("2d");
  }
}