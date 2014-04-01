require 'spec_helper'

describe 'Appraisals file Bundler DSL compatibility' do
  it 'supports all Bundler DSL in Appraisals file' do
    build_gems %w(bagel orange_juice milk)
    build_git_gem 'egg'

    build_gemfile <<-Gemfile
      source 'https://rubygems.org'
      ruby RUBY_VERSION

      gem 'bagel'

      git '../gems/egg' do
        gem 'egg'
      end

      group :breakfast do
        gem 'orange_juice'
      end

      platforms :ruby, :jruby do
        gem 'milk'
      end

      gem 'appraisal', path: #{PROJECT_ROOT.inspect}
    Gemfile

    build_appraisal_file <<-Appraisals
      appraise 'breakfast' do
        source 'http://some-other-source.com'
        ruby "1.8.7"

        gem 'bread'

        git '../gems/egg' do
          gem 'porched_egg'
        end

        group :breakfast do
          gem 'bacon'
        end

        platforms :ruby, :jruby do
          gem 'yoghurt'
        end
      end
    Appraisals

    run 'bundle install --local'
    run 'appraisal generate'

    expect(content_of 'gemfiles/breakfast.gemfile').to eq <<-Gemfile.strip_heredoc
      # This file was generated by Appraisal

      source "https://rubygems.org"
      source "http://some-other-source.com"

      ruby "1.8.7"

      git "../gems/egg" do
        gem "egg"
        gem "porched_egg"
      end

      gem "bagel"
      gem "appraisal", :path=>#{PROJECT_ROOT.inspect}
      gem "bread"

      group :breakfast do
        gem "orange_juice"
        gem "bacon"
      end

      platforms :ruby, :jruby do
        gem "milk"
        gem "yoghurt"
      end
    Gemfile
  end
end
