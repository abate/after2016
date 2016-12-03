Package.describe({
    name: 'drblue:fullcalendar',
    summary: "Meteor-package of FullCalendar.io with Scheduler-plugin",
    version: "3.0.1",
    git: "https://github.com/drblue/meteor-fullcalendar-scheduler.git"
});

Package.onUse(function(api) {
    api.versionsFrom('METEOR@0.9.2.2');
    api.use([
        'momentjs:moment@2.8.4',
        'templating',
        'jquery'
    ], 'client');
    api.addFiles([
        'fullcalendar/dist/fullcalendar.js',
        'fullcalendar/dist/fullcalendar.css',
        'fullcalendar-scheduler/dist/scheduler.css',
        'fullcalendar-scheduler/dist/scheduler.js',
        'fullcalendar/dist/locale-all.js',
        'fullcalendar/dist/gcal.js',
        'template.html',
        'template.js'
    ], 'client');
});
