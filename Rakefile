require "open-uri"
require "yaml"
require_relative "scripts/rake_tasks.rb"

CONFIG = "etc/config.yml"
OPTS = File.open(CONFIG, mode='r') { |f| YAML.load(f) }

REPORT_NAME = OPTS['report_name']
BUILD_DIR = "build"

MASTER_MD_FILE = "#{BUILD_DIR}/#{REPORT_NAME}.md"
MASTER_TEX_FILE = "#{BUILD_DIR}/#{REPORT_NAME}.tex"
MASTER_PDF_FILE = "#{BUILD_DIR}/#{REPORT_NAME}.pdf"
MASTER_DOC_FILE = "#{BUILD_DIR}/#{REPORT_NAME}.docx"

ANALYSIS_R    = "app/analysis.r"

R_LIBRARIES = ["rmarkdown", "pander"]
RMD_TO_MD_FILES = [
    {rmd: "", md: ""}
]

DOC_TEMPLATE='templates/apa6_man.docx'

TEX_TEMPLATE='templates/apa6.tex'
TEMPLATES_TEX_APA = "templates/tex/apa-"
TEX_APA_HEADER = "#{TEMPLATES_TEX_APA}header.tex"
TEX_APA_DOC = "#{TEMPLATES_TEX_APA}begin-doc.tex"
TEX_APA_FOOTER = "#{TEMPLATES_TEX_APA}footer.tex"


task :default => [:build]

desc "Build and view PDF report"
task :build => [:merge, :md2tex, :tex2pdf, :skim]

desc "Download APA styles (version 6) CSL file"
task :csl do
    File.open(OPTS['csl'], 'w') do |fo|
        fo.write open(OPTS['csl_url']).read
    end
end

desc "Create project directories"
task :dirs do
    sh "mkdir -v -p build etc"
end

desc "Initialize repository"
task :init => [:dirs, :csl]


desc "Merge all markdown files from /text directory, as per index.yml."
task :merge do
    RakeTasks.merge("./text/index.yml", MASTER_MD_FILE)
end

desc "Convert master markdown file to LaTeX."
task :md2tex do
    sh """pandoc --smart --standalone \
        --template #{TEX_TEMPLATE} \
        --parse-raw \
        --bibliography #{OPTS['refs']} --natbib -V biblio-style:apa \
        #{CONFIG} \
        #{MASTER_MD_FILE} \
        --output=#{MASTER_TEX_FILE}"""
end

desc "Convert master markdown file to DOCX."
task :md2docx => [:merge, :md2tex] do
    sh """pandoc --smart --standalone \
        --parse-raw \
        --reference-docx=#{DOC_TEMPLATE} \
        --bibliography=#{OPTS['refs']} \
        --csl=#{OPTS['csl']} \
        #{CONFIG} \
        #{MASTER_MD_FILE} --output=#{MASTER_DOC_FILE}
        """
end

desc "Convert master LaTeX file to PDF."
task :tex2pdf do
    sh "pdflatex -output-directory #{BUILD_DIR} #{MASTER_TEX_FILE}"
    sh "bibtex #{BUILD_DIR}/#{REPORT_NAME}.aux"
    sh "pdflatex -output-directory #{BUILD_DIR} #{MASTER_TEX_FILE}"
    sh "pdflatex -output-directory #{BUILD_DIR} #{MASTER_TEX_FILE}"
end

desc "Convert RMD files to MD"
task :rmd2md do
    rscript_cmd = "Rscript "

    R_LIBRARIES.each do |lib|
        rscript_cmd << "-e \"library('#{lib}')\" "
    end

    RMD_TO_MD_FILES.each do |file|
        _rmd_file = File.expand_path(file[:rmd])
        _md_file = File.expand_path(file[:md])
        rscript_cmd << "-e \"render(input = '#{_rmd_file}', output_file = '#{_md_file}')\" "
    end

    sh rscript_cmd
end

desc "Open report in Skim.app"
task :skim do
    sh "skim #{MASTER_PDF_FILE}"
end

desc "Clean LaTeX metadata files."
task :clean do
    sh "cd #{BUILD_DIR}; latexmk -c"
end

desc "Watch text files for changes and regenerate master markdown file, as appropriate."
task :watch do
    sh "fswatch ./text/. 'rake merge'"
end
