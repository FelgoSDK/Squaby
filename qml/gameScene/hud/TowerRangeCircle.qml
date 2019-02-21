import QtQuick 2.0
import Felgo 3.0

// this component gets used for dragging the tower outside, and for indicating the radius of a selected tower
MultiResolutionImage {
    id: rangeCircle
    // this is the green circle, indicating that either building a tower is allowed when dragging a tower to the playfield, or when the radius of a selected tower should be displayed
    // it is visually better to use a big image and scale it down than scaling it up!
    // TODO this is still not ideal, because for every different collider size an own image could be used with the correct size so no scaling would be required
    // the drawback is that then all collider sizes defined in the logic must be provided as images!
    // and considering that only 1 collider is shown at a single time and not that often (only when a tower is selected), this scaling in the logic here is a reasonable approach (which is also able to adapt to all collider sizes of the logic)
    source: "../../../assets/img/menu_labels/range_radius_allowed.png"
    opacity: 0.5
    property bool isAllowedToBuild: true
    property real colliderRadius: 80

    width: colliderRadius*2
    height: colliderRadius*2

    onIsAllowedToBuildChanged: {
        if(!isAllowedToBuild)
            source = "../../../assets/img/menu_labels/range_radius_forbidden.png";
        else
            source = "../../../assets/img/menu_labels/range_radius_allowed.png"
    }
}
