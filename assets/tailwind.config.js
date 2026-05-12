// Tailwind config — scans these paths for class names and generates CSS.
module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/kanban_web.ex",
    "../lib/kanban_web/**/*.*ex",
    "../lib/kanban_web/**/*.heex",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};
