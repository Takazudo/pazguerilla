/**
 * grunt
 * coffeelint-compile example
 */
module.exports = function(grunt){

  grunt.initConfig({
    coffee: {
      app: {
        files: [ 'coffee/app.coffee' ],
        dest: 'js/app.js'
      }
    },
    coffeelint: {
      app: {
        files: '<config:coffee.app.files>'
      }
    },
    watch: {
      app: {
        files: '<config:coffee.app.files>',
        tasks: 'coffeelint:app coffee:app ok'
      }
    }
  });

  grunt.loadTasks('tasks');
  grunt.registerTask('default', 'coffeelint coffee ok');

};
