# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Sanitizer do
  subject(:sanitizer) { described_class.new }

  describe "#call" do
    it "allows custom CSS properties" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head> <style type="text/css"> .screen { --screen-w: 1040px; --screen-h: 780px; --pixel-ratio: 1.8; --dither-pixel-ratio: 2.0; --ui-scale: 1.0; --gap-scale: 1.0; } </style> </head> <body></body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows canvas element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head></head>
          <body>
            <canvas id="test-canvas" width="300" height="150"></canvas>
        </body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows circle element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head></head>
          <body>
            <circle cx="5" cv="5" r="5" stroke="#000" stroke-dasharray="6,7" stroke-dashoffset="5" stroke-opacity="0.5" stroke-width="5" fill="#FFF" fill-opacity="0.5" shape-rendering="crispEdges" transform="scale(5)"></circle>
        </body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows defs element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head></head>
          <body>
            <defs id="1"></defs>
        </body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows div element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head></head>
          <body>
            <div data-list-limit="true"></div>
        </body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows ellipse element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head></head>
          <body>
            <ellipse cx="5" cv="5" rx="5" rv="5" stroke="#000" stroke-dasharray="6,7" stroke-dashoffset="5" stroke-opacity="0.5" stroke-width="5" fill="#FFF" fill-opacity="0.5" shape-rendering="crispEdges" transform="scale(5)"></ellipse>
        </body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows g element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head></head>
          <body>
            <g stroke="#000" stroke-width="5" fill="#FFF" transform="scale(5)"></g>
        </body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows line element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head></head>
          <body>
            <line x1="5" x2="5" v1="5" v2="5" stroke="#000" stroke-dasharray="6,7" stroke-dashoffset="5" stroke-linecap="round" stroke-width="5" shape-rendering="crispEdges" transform="scale(5)"></line>
        </body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows link element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head> <link rel="stylesheet" href="https://trmnl.com/css/latest/plugins.css">
        </head><body></body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows path element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head></head>
          <body>
            <path d="M10 10" stroke="#000" stroke-dasharray="6,7" stroke-dashoffset="5" stroke-linecap="round" stroke-linejoin="round" stroke-opacity="0.5" stroke-width="5" fill="#FFF" fill-opacity="0.5" shape-rendering="crispEdges" transform="scale(5)"></path>
        </body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows poylgon element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head></head>
          <body>
            <polygon points="0,0 50,0 25,50" stroke="#000" stroke-dasharray="6,7" stroke-dashoffset="5" stroke-linejoin="round" stroke-opacity="0.5" stroke-width="5" fill="#FFF" fill-opacity="0.5" shape-rendering="crispEdges" transform="scale(5)"></polygon>
        </body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows polyline element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head></head>
          <body>
            <polyline points="0,0 50,0 25,50" stroke="#000" stroke-dasharray="6,7" stroke-dashoffset="5" stroke-linecap="round" stroke-linejoin="round" stroke-opacity="0.5" stroke-width="5" fill="#FFF" fill-opacity="0.5" shape-rendering="crispEdges" transform="scale(5)"></polyline>
        </body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows rect element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head></head>
          <body>
            <rect x="5" y="5" width="5" height="5" rx="5" ry="5" stroke="#000" stroke-dasharray="6,7" stroke-dashoffset="5" stroke-linejoin="round" stroke-opacity="0.5" stroke-width="5" fill="#FFF" fill-opacity="0.5" shape-rendering="crispEdges" transform="scale(5)"></rect>
        </body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows script element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head> <script src="https://trmnl.com/js/latest/plugins.js"></script>
        </head><body></body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows style element with attributes" do
      element = <<~HTML.strip
        <html><head>
            <style title="Test" type="text/css" media="all">
              * {
                margin: 0;
              }
            </style>
          </head>
          <body>
        </body></html>
      HTML

      expect(sanitizer.call(element)).to eq(element)
    end

    it "allows source element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head></head>
          <body>
            <source src="https://test.io/one.png"
                    type="image/png"
                    srcset="https://test.io/a-tiny.png 10vw, https://test.io/a-small.png 100vw"
                    sizes="100vw, 10vw"
                    media="(max-width: 600px)"
                    height="10"
                    width="10">
        </body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows svg element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head></head>
          <body>
            <svg version="1.0.0" viewBox="0 0 10 10" width="5" height="5" x="5" y="5" shape-rendering="crispEdges"></svg>
        </body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows text element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head></head>
          <body>
            <text x="5" y="5" dx="5" dy="5" rotate="5" stroke="#000" stroke-dasharray="6,7" stroke-dashoffset="5" stroke-linecap="round" stroke-linejoin="round" stroke-opacity="0.5" stroke-width="5" fill="#FFF" fill-opacity="0.5" transform="scale(5)"></text>
        </body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end

    it "allows tspan element with attributes" do
      source = <<~HTML.squeeze(" ").delete("\n").strip
        <html><head></head>
          <body>
            <tspan x="5" y="5" dx="5" dy="5" rotate="5" stroke="#000" stroke-dasharray="6,7" stroke-dashoffset="5" stroke-linecap="round" stroke-linejoin="round" stroke-opacity="0.5" stroke-width="5" fill="#FFF" fill-opacity="0.5"></tspan>
        </body></html>
      HTML

      expect(sanitizer.call(source)).to eq(source)
    end
  end
end
