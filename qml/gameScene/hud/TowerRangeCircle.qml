import QtQuick 1.0

// this component gets used for dragging the tower outside, and for indicating the radius of a selected tower
Image {
    id: rangeCircle
    // this is the green circle, indicating that either building a tower is allowed when dragging a tower to the playfield, or when the radius of a selected tower should be displayed
    // it is visually better to use a big image and scale it down than scaling it up!
    // TODO this is still not ideal, because for every different collider size an own image could be used with the correct size so no scaling would be required
    // the drawback is that then all collider sizes defined in the logic must be provided as images!
    // and considering that only 1 collider is shown at a single time and not that often (only when a tower is selected), this scaling in the logic here is a reasonable approach (which is also able to adapt to all collider sizes of the logic)
    source: "../../img/range_radius80_allowed.png"
    opacity: 0.5
    property bool isAllowedToBuild: true
    // TODO use this for scaling the image to the real size
    //property real colliderSize: 32
    property real colliderRadius: sourceSize.width/2

    Component.onCompleted: {
        // this must be called here as well, because colliderRadius might get set from the beginning, not leading to a onColliderRadiusChanged-call
        calculateScaleFactorFromColliderRadius();
    }

    onColliderRadiusChanged: {
        calculateScaleFactorFromColliderRadius();
    }

    onIsAllowedToBuildChanged: {
        // ranges00 is the red circle
        if(!isAllowedToBuild)
            source = "../../img/range_radius80_forbidden.png";
        else
            source = "../../img/range_radius80_allowed.png"
    }

    function calculateScaleFactorFromColliderRadius() {
        // the image has a collider radius of 32 (and its size is thus 64)
        // so with a colliderSize of 32, the scaleFactor is 1.0
        var scaleFactor = colliderRadius/(sourceSize.width/2);
        if(scaleFactor===1)
            console.log("ideal scale factor of 1 for the collider")
        else {
            console.log("non-ideal scale factor unequal 1:" + scaleFactor)
            // TODO to prevent scaling, a version for each scale factor could be used..
        }

        width=sourceSize.width*scaleFactor;
        height=sourceSize.height*scaleFactor;
    }

    // solve this rather by anchoring in the calling hud.qml
    // the pinning x/y point should be the center, not the top left of the image
//    transform: [
//        Translate { x: -width/2; y: -height/2}
//    ]
}
