function wbucb(src,~)
%this function will be called when the user stop pressing the mouse button.
%It calls a second buttonDown function that will signal the end of the ROI.
set(src,'WindowButtonUpFcn','')
set(src,'WindowButtonDownFcn',@wbdcb_II)