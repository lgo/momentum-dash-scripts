(function() {
  'use strict';

  function setHtnTime() {
    var millisecondsLeft = (new Date("Sept. 16 2016, 15:00")) - (new Date());
    var secondsLeft = Math.round(millisecondsLeft / 1000) % 60;
    var minutesLeft = Math.round(millisecondsLeft / 1000 / 60) % 60;
    var hoursLeft = Math.round(millisecondsLeft / 1000 / 60 / 60) % 24;
    var daysLeft = Math.floor(millisecondsLeft / 1000 / 60 / 60 / 24);

    $("#htn-hours").text(hoursLeft);
    $("#htn-days").text(daysLeft);
    $("#htn-minutes").text(minutesLeft);
    $("#htn-seconds").text(secondsLeft);
  }

  $(() => {
    $("#center-above").prepend(`
      <h2>
        <span id='htn-days'></span> days,
        <span id='htn-hours'></span> hours,
        <span id='htn-minutes'></span> minutes,
        and <span id='htn-seconds'></span> seconds
        until Hack the North!
      </h2>
    `);

    setHtnTime();
    setInterval(setHtnTime, 1000);
  })
})();
