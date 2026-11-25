# Comprueba que todos los enlaces y recursos internos (href/src) de la web generada apuntan a un archivo que existe.
# Sirve sobre todo para cazar rutas que se saltan la ruta base (baseurl) cuando la web vive en una subcarpeta.
#
# Uso: ruby .github/comprobar-enlaces.rb _site "/ruta-base"   (ruta base vacía para la web principal)
require "cgi"
require "pathname"

sitio = Pathname(ARGV[0] || "_site").expand_path
base = (ARGV[1] || "").chomp("/")
abort "No existe #{sitio}" unless sitio.directory?

EXTERNO = %r{\A(?:[a-z][a-z0-9+.-]*:|//|#)}i # https:, mailto:, data:, //cdn…, #ancla
errores = []
revisados = 0

Dir.glob(sitio.join("**/*.html").to_s).sort.each do |archivo|
  pagina = Pathname(archivo)
  html = File.read(archivo)
  html = html.gsub(/<script\b.*?<\/script>/m, "") # el JS no cuenta
  html.scan(/\s(?:href|src)="([^"]*)"/).flatten.uniq.each do |url|
    url = CGI.unescapeHTML(url)
    next if url.empty? || url.match?(EXTERNO) || url.include?("{{")
    ruta = url.split(/[?#]/, 2).first
    next if ruta.nil? || ruta.empty?

    destino =
      if ruta.start_with?("/")
        if !base.empty? && !(ruta == base || ruta.start_with?("#{base}/"))
          errores << "#{pagina.relative_path_from(sitio)}: «#{url}» no lleva la ruta base #{base}"
          next
        end
        sitio.join(ruta.delete_prefix(base).delete_prefix("/"))
      else
        pagina.dirname.join(ruta)
      end
    destino = destino.join("index.html") if destino.directory? || ruta.end_with?("/")
    revisados += 1
    errores << "#{pagina.relative_path_from(sitio)}: «#{url}» no existe" unless destino.file?
  end
end

if errores.empty?
  puts "Enlaces internos correctos (#{revisados} comprobados, ruta base «#{base}»)."
else
  puts errores.uniq.map { |e| "::error::#{e}" }
  abort "#{errores.uniq.size} enlace(s) roto(s)."
end
