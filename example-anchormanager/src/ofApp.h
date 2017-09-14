#pragma once

#include "ofxiOS.h"
#include <ARKit/ARKit.h>
#include "ofxARKit.h"

#define LENGTH 44100 * 3

class ofApp : public ofxiOSApp {
    
public:
    
    ofApp (ARSession * session);
    ofApp();
    ~ofApp ();
    
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs &touch);
    void touchMoved(ofTouchEventArgs &touch);
    void touchUp(ofTouchEventArgs &touch);
    void touchDoubleTap(ofTouchEventArgs &touch);
    void touchCancelled(ofTouchEventArgs &touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    void audioIn( float * input, int bufferSize, int nChannels );
    void audioOut( float * output, int bufferSize, int nChannels );

    
    ofTrueTypeFont font;
    
    
    // ====== AR STUFF ======== //
    ARSession * session;
    ARCore::AnchorManagerRef anchors;
    ARRef processor;
    
    ofImage img;
    
    // Sound
    float buffer[LENGTH]; // 録音バッファ
    int sampleRate;       // サンプリングレート
    int recPos;           // 録音位置
    int playPos;          // 再生位置
    int mode;             // 録音 or 再生モード
    
    
};


