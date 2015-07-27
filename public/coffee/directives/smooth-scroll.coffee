# https://gist.github.com/justinmc/d72f38339e0c654437a2
# Edited for the 50px header bar
App.directive 'anchorSmoothScroll', [
    '$location'
    '$state'
    '$timeout'
    ($location, $state, $timeout) ->
        {
        restrict: 'A'
        replace: false
        scope:
            'anchorSmoothScroll': '@'
            'uiSref': '@'
        link: ($scope, $element, $attrs) ->

            ### initialize -
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            ###

            initialize = ->
                createEventListeners()
                return

            ### createEventListeners -
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            ###

            createEventListeners = ->
                # listen for a click
                $element.on 'click', ->
                    # go to specifi state if required
                    if $scope.uiSref?
                        $state.go $scope.uiSref
                        return $timeout ->
                            scrollTo $scope.anchorSmoothScroll
                        , 0
                    # smooth scroll to the passed in element
                    scrollTo $scope.anchorSmoothScroll

            ### scrollTo -
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            ###

            scrollTo = (eID) ->
                # This scrolling function
                # is from http://www.itnewb.com/tutorial/Creating-the-Smooth-Scroll-Effect-with-JavaScript
                i = undefined
                startY = currentYPosition()
                stopY = elmYPosition(eID) - 50
                distance = if stopY > startY then stopY - startY else startY - stopY
                if distance < 100
                    scrollTo 0, stopY
                    return
                speed = Math.round(distance / 400)
                if speed >= 20
                    speed = 20
                step = Math.round(distance / 150)
                leapY = if stopY > startY then startY + step else startY - step
                timer = 0
                if stopY > startY
                    i = startY
                    while i < stopY
                        setTimeout 'window.scrollTo(0, ' + leapY + ')', timer * speed
                        leapY += step
                        if leapY > stopY
                            leapY = stopY
                        timer++
                        i += step
                    return
                i = startY
                while i > stopY
                    setTimeout 'window.scrollTo(0, ' + leapY + ')', timer * speed
                    leapY -= step
                    if leapY < stopY
                        leapY = stopY
                    timer++
                    i -= step
                return

            ### currentYPosition -
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            ###

            currentYPosition = ->
                # Firefox, Chrome, Opera, Safari
                if window.pageYOffset
                    return window.pageYOffset
                # Internet Explorer 6 - standards mode
                if document.documentElement and document.documentElement.scrollTop
                    return document.documentElement.scrollTop
                # Internet Explorer 6, 7 and 8
                if document.body.scrollTop
                    return document.body.scrollTop
                0

            ### scrollTo -
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            ###

            elmYPosition = (eID) ->
                elm = document.getElementById(eID)
                y = elm.offsetTop
                node = elm
                while node.offsetParent and node.offsetParent != document.body
                    node = node.offsetParent
                    y += node.offsetTop
                y

            initialize()
            return
        }
]