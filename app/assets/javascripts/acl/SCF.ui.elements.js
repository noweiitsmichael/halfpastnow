(function() {
function Appreciate() {
}

var klass = Appreciate.prototype;
var self = Appreciate;
SCF.Appreciate = Appreciate;

self.init = function() {
    self.bindEvents();
};

self.bindEvents = function() {
    $(self.element).click(function() {
        $(this).toggleClass("tnx");
    });
}

// vars
self.element = ".appreciate";

}());
(function() {
function Checkbox(element) {
    this.element = element;
}

var klass = Checkbox.prototype;
var self = Checkbox;
SCF.Checkbox = Checkbox;

klass.init = function() {
    this.bindEvents();
};

klass.bindEvents = function() {
    var _this = this;

    $(this.element).click(function() {
        $(this).toggleClass("checked");
    });
}

}());
(function() {
function Commutator() {
}

var klass = Commutator.prototype;
var self = Commutator;
SCF.Commutator = Commutator;

self.init = function() {
    self.bindEvents();
};

self.bindEvents = function() {
    $(self.element).mousedown(function() {
        if ($(this).hasClass("off")) {
            $(this).removeClass("off").addClass("on");
        } else {
            $(this).addClass("off").removeClass("on");
        }
    });
};

// vars
self.element = ".commutator";

}());
(function() {
function CurrentlyPlaying(element) {
    this.element    = element;
    this.scale      = this.element + " .js-currently-playing-scale";
    this.hitbox     = this.element + " .js-currently-playing-hitbox";
}

var klass = CurrentlyPlaying.prototype;
var self = CurrentlyPlaying;
SCF.CurrentlyPlaying = CurrentlyPlaying;

klass.init = function() {
    this.bindEvents();
};

klass.bindEvents = function() {
    var _this = this;
    var scaleInitialWidth = $(this.scale).width();
    var scrollboxWidth = $(this.hitbox).width();

    // Slider mechanics
    $(this.hitbox).slider({
        slide: function(event, ui){
            var scaleWidth = ui.value;

            $(_this.scale).css({
                'width': scaleWidth
            });
        },
        max: scrollboxWidth,
        value: scaleInitialWidth
    });
}

}());
(function() {
function Datepicker() {
}

var klass = Datepicker.prototype;
var self = Datepicker;
SCF.Datepicker = Datepicker;

self.init = function() {
    self.bindEvents();
};

self.bindEvents = function() {
    $(self.element).datepicker({
        showButtonPanel: true,
        minDate: -20,
        maxDate: "+1M +10D",
        dayNamesMin: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        firstDay: 1
    });
};

// vars
self.element = ".datepicker-placeholder";

}());
(function() {
function Equalizer() {
}

var klass = Equalizer.prototype;
var self = Equalizer;
SCF.Equalizer = Equalizer;

self.init = function() {
    self.bindEvents();
};

self.bindEvents = function() {
    $(self.bar).each(function() {
        // Get a default value for all bars
        var scaleInitialHeight = $(this).find(self.scale).height();

        // Slider mechanics
        $(this).slider({
            slide: function(event, ui){
                var scaleHeight = ui.value;

                $(this).find(self.scale).css({
                    'height': scaleHeight
                });
            },
            max: 114,
            orientation: 'vertical',
            value: scaleInitialHeight
        });
    });
};

// vars
self.element = ".equalizer";
self.bar = self.element + " .equalizer-bar";
self.scale = ".equalizer-scale";

}());
(function() {
function Pagination() {
}

var klass = Pagination.prototype;
var self = Pagination;
SCF.Pagination = Pagination;

self.init = function() {
    self.bindEvents();
};

self.bindEvents = function() {
    $(self.paginationLink).click(function() {
        $(this).siblings().removeClass("active");
        $(this).addClass("active");
    });
}

// vars
self.element = ".pagination";
self.paginationLink = self.element + " li";

}());
(function() {
function Player(element) {
    this.element          = element;
    this.volumeScale      = this.element + " .js-volume-scale";
    this.volumeBar        = this.element + " .js-volume-bar";
}

var klass = Player.prototype;
var self = Player;
SCF.Player = Player;

klass.init = function() {
    this.bindEvents();
};

klass.bindEvents = function() {
    var _this = this;

    $(this.element).click(function() {
        _this.toggleVolume();
    });

    $(this.volumeScale).mousedown(function(event) {
        $(this).mousemove(function(event) {
            _this.setVolume(event);
        });

        $(this).mouseup(function(event) {
            $(this).unbind("mousemove");
            _this.collapseVolume();
        });
    });

    $(this.volumeScale).click(function(event) {
        _this.setVolume(event);
    });
}

klass.setVolume = function(event) {
    var offsetLeftValue  = $(this.volumeScale).offset().left;
    var trackPosition    = event.pageX - offsetLeftValue - 12;
    var volumeScaleWidth = $(this.volumeScale).width() * 1.06;
    var volumeBarWidth   = trackPosition * 100 / volumeScaleWidth;
    $(this.volumeBar).width(volumeBarWidth + "%");
}

klass.toggleVolume = function() {
    var _this = this;

    if ($(this.element).hasClass("opened")) {
        _this.collapseVolume();
    } else {
        _this.expandVolume();
    }
};

klass.expandVolume = function() {
    $(this.element).addClass("opened");
};

klass.collapseVolume = function() {
    var _this = this;

    setTimeout(function() {
        $(_this.element).removeClass("opened");
    }, 300);
};

}());
(function() {
function Radio(radioGroup) {
    this.radioGroup = radioGroup;
    this.radio = this.radioGroup + " .js-radio";
}

var klass = Radio.prototype;
var self = Radio;
SCF.Radio = Radio;

klass.init = function() {
    this.bindEvents();
};

klass.bindEvents = function() {
    var _this = this;

    $(this.radio).click(function() {
        $(_this.radio).removeClass("checked");
        $(this).addClass("checked");
    });
}

}());
(function() {
function Scrollbox() {
}

var klass = Scrollbox.prototype;
var self = Scrollbox;
SCF.Scrollbox = Scrollbox;

self.init = function() {
    self.bindEvents();
};

self.bindEvents = function() {
    $(self.element).each(function() {
        // Get a default value for all bars
        var scaleInitialWidth = $(this).find(self.scale).width();
        var scrollboxWidth = $(this).find(self.hitbox).width();

        // Slider mechanics
        $(this).find(self.hitbox).slider({
            slide: function(event, ui){
                var scaleWidth = ui.value;

                $(this).next(self.scale).css({
                    'width': scaleWidth
                });
            },
            max: scrollboxWidth,
            value: scaleInitialWidth
        });
    });
};

// vars
self.element = ".js-scrollbox";
self.scale = ".scale";
self.hitbox = ".hitbox";

}());
(function() {
function Slideshow(element) {
    this.element     = element;
    this.slides      = this.element + " .js-slideshow-slides";
    this.slide       = this.element + " .js-slideshow-slide";
    this.nextSlide   = this.element + " .js-slideshow-next-slide";
    this.prevSlide   = this.element + " .js-slideshow-prev-slide";
    this.slidesCount = $(this.slide).size();
    this.slideWidth  = $(this.slide).width();
    this.slidesWidth = this.slideWidth * this.slidesCount;
}

var klass = Slideshow.prototype;
var self = Slideshow;
SCF.Slideshow = Slideshow;

klass.init = function() {
    this.setSlidesWidth();
    this.bindEvents();
};

klass.bindEvents = function() {
    var _this = this;

    $(this.nextSlide).click(function() {
        _this.showNextSlide();
    });

    $(this.prevSlide).click(function() {
        _this.showPrevSlide();
    });
}

klass.setSlidesWidth = function() {
    $(this.slides).width(this.slidesWidth);
}

klass.showNextSlide = function() {
    var _this = this;
    var currentSlidesPosition = $(this.slides).position().left;
    var slideShiftWidth       = currentSlidesPosition - this.slideWidth;
    var lastSlidePosition     = (1 - this.slidesCount) * this.slideWidth;

    $(this.slides).css("left", slideShiftWidth);

    if (currentSlidesPosition <= lastSlidePosition) {
        $(_this.slides).css("left", 0);
    }
};

klass.showPrevSlide = function() {
    var _this = this;
    var currentSlidesPosition = $(this.slides).position().left;
    var slideShiftWidth       = currentSlidesPosition + this.slideWidth;
    var firstSlidePosition    = this.slideWidth - this.slidesWidth;

    $(this.slides).css("left", (slideShiftWidth));

    if (currentSlidesPosition >= 0) {
        $(_this.slides).css("left", firstSlidePosition);
    }
};

}());
(function() {
function Starbar(element, rating) {
    this.element = element;
    this.rating = rating;
    this.star = this.element + " .star";
}

var klass = Starbar.prototype;
var self = Starbar;
SCF.Starbar = Starbar;

klass.init = function() {
    this.setDefaultRating();
    this.bindEvents();
};

klass.bindEvents = function() {
    var _this = this;

    $(this.star).hover(function() {
        _this.fillRatingUntil(this);
    }, function() {
        _this.setDefaultRating();
    });

    $(this.star).click(function() {
        $(_this.star).unbind();
    });
};

klass.setDefaultRating = function() {
    var last = $(this.star).eq(this.rating - 1);
    this.clearRating();
    this.fillRatingUntil(last);
};

klass.clearRating = function() {
    $(this.star).removeClass("full focus");
};

klass.fillRatingUntil = function(star) {
    this.clearRating();
    $(star).addClass("full focus");
    $(star).prevAll().addClass("full focus");
};

}());
(function() {
function Tabbox(element) {
    this.element = element;
    this.tabboxStuff = this.element + " .tabbox-stuff";
    this.tabboxTabs = this.element + " .tabbox-tabs";
    this.tabboxTab = this.tabboxTabs + " li";
    this.activeTabIndex = null;
}

var klass = Tabbox.prototype;
var self = Tabbox;
SCF.Tabbox = Tabbox;

klass.init = function() {
    this.storeActiveTabIndex();
    this.openCorrectTabContent();
    this.bindEvents();
};

klass.bindEvents = function() {
    var _this = this;

    $(this.tabboxTab).click(function() {
        _this.switchTabs(this);
    });
};

klass.openCorrectTabContent = function() {
    $(this.tabboxStuff).addClass("hidden");
    $(this.tabboxStuff).eq(this.activeTabIndex).removeClass("hidden");
};

klass.storeActiveTabIndex = function() {
    var _this = this;

    $(this.tabboxTab).each(function(index) {
        if ($(this).hasClass("active")) {
            _this.activeTabIndex = index;
        }
    });
};

klass.switchTabs = function(tab) {
    $(this.tabboxTab).removeClass("active");
    $(tab).addClass("active");
    this.storeActiveTabIndex();
    this.openCorrectTabContent();
}

}());
