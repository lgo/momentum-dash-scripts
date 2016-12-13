(function() {
  'use strict';

  // FIXME(xLegoz): Allow event and target to be cli arguments for script install
  var countdownEvent = "Hack the North";
  var countdownTarget = "Sept. 16 2016, 15:00";

  function setCountdownTime() {
    var millisecondsLeft = (new Date(countdownTarget)) - (new Date());
    var secondsLeft = Math.round(millisecondsLeft / 1000) % 60;
    var minutesLeft = Math.round(millisecondsLeft / 1000 / 60) % 60;
    var hoursLeft = Math.round(millisecondsLeft / 1000 / 60 / 60) % 24;
    var daysLeft = Math.floor(millisecondsLeft / 1000 / 60 / 60 / 24);

    $("#countdown-hours").text(hoursLeft);
    $("#countdown-days").text(daysLeft);
    $("#countdown-minutes").text(minutesLeft);
    $("#countdown-seconds").text(secondsLeft);
  }


  $(() => {
    $("#center-above").prepend(`
      <h2>
        <span id='countdown-days'></span> days,
        <span id='countdown-hours'></span> hours,
        <span id='countdown-minutes'></span> minutes,
        and <span id='countdown-seconds'></span> seconds
        until ${countdownEvent}!
      </h2>
    `);

    setCountdownTime();
    setInterval(setCountdownTime, 1000);
  })
})();
