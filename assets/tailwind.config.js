module.exports = {
  purge:[
    "./js/**/*.js",
    "../lib/ex338_web/**/*.html",
    "../lib/ex338_web/**/*.ex",
    "../lib/ex338_web/**/*.eex",
    "../lib/ex338_web/**/*.leex",
    "../lib/ex338_web/**/*.md"
  ],
  theme: {
    extend: {}
  },
  variants: {
    margin: ["responsive", "first", "last"],
    padding: ["responsive", "first", "last"]
  },
  plugins: [require("@tailwindcss/ui"), require("@tailwindcss/typography")]
};
