import QtQuick 2.0

// this text adapts its size to the width of the parent, if the parent is smaller than the current text
Text {
    id: textItem

    property int padding: 7
    property int parentWidth: parent.width-(2 * padding)
    property int savedPixelSize

    Component.onCompleted: {
        adjustSize();
    }

    onFontChanged: {
        //save the original pixel size so it can be reset when the text changes
        if(!savedPixelSize) savedPixelSize = font.pixelSize;
    }

    onTextChanged: {
        if(savedPixelSize) font.pixelSize = savedPixelSize;
        adjustSize()
    }

    function adjustSize() {
        // decrease the font size until the text fits
        while(width > parentWidth && parentWidth > 1) {
            textItem.font.pixelSize--;
        }
    }
}
