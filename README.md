# chan-image

`chan-image` is a general image board downloader.

# Setup

Install `stack`, then run `stack build`. You can also just download
pre-compiled binaries, currently only x86_64 linux is supported.

# Usage

After building from `stack build`, you can run `stack exec chan-image-exe <url> <folder_name>`
to save all the images in `url` to `folder_name`.

# Checklist

- [ ] support various other image boards
- [ ] use API instead of HTML scraping if the site provides an API
- [ ] HTTPS
- [ ] rate limiting, to be Nice
