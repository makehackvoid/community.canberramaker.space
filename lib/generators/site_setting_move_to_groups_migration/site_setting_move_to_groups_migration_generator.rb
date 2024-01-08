# frozen_string_literal: true

class SiteSettingMoveToGroupsMigrationGenerator < Rails::Generators::Base
  include SiteSettingExtension

  argument :old_name, type: :string, banner: "old setting name", required: true
  argument :new_name, type: :string, banner: "new setting name", required: true

  def create_migration_file
    migration_version = ActiveRecord::Migration.next_migration_number(0)
    file_path = "db/migrate/#{migration_version}_fill_#{new_name}_based_on_deprecated_setting.rb"
    class_name = "Fill#{new_name.classify}BasedOnDeprecatedSetting"

    validate_setting_name!(old_name)
    validate_setting_name!(new_name)
    validate_setting_type!(old_name)

    create_file file_path, <<~MIGRATION_FILE if setting_type(old_name) == "TrustLevelSetting"
        # frozen_string_literal: true

        class #{class_name} < ActiveRecord::Migration[7.0]
          def up
            old_setting_trust_level =
              DB.query_single(
                "SELECT value FROM site_settings WHERE name = '#{old_name}' LIMIT 1",
              ).first

            if old_setting_trust_level.present?
              allowed_groups = "1\#\{old_setting_trust_level\}"

              DB.exec(
                "INSERT INTO site_settings(name, value, data_type, created_at, updated_at)
                VALUES('#{new_name}', :setting, '20', NOW(), NOW())",
                setting: allowed_groups,
              )
            end
          end

          def down
            raise ActiveRecord::IrreversibleMigration
          end
        end
      MIGRATION_FILE
    if setting_type(old_name) == "TrustLevelAndStaffSetting"
      create_file file_path, <<~MIGRATION_FILE
        # frozen_string_literal: true

        class #{class_name} < ActiveRecord::Migration[7.0]
          def up
            old_setting_trust_level =
              DB.query_single(
                "SELECT value FROM site_settings WHERE name = '#{old_name}' LIMIT 1",
              ).first

            if old_setting_trust_level.present?
              allowed_groups =
                case old_setting_trust_level
                when "admin"
                  "1"
                when "staff"
                  "3"
                when "0"
                  "10"
                when "1"
                  "11"
                when "2"
                  "12"
                when "3"
                  "13"
                when "4"
                  "14"
                end

              DB.exec(
                "INSERT INTO site_settings(name, value, data_type, created_at, updated_at)
                VALUES('#{new_name}', :setting, '20', NOW(), NOW())",
                setting: allowed_groups,
              )
            end
          end

          def down
            raise ActiveRecord::IrreversibleMigration
          end
        end
      MIGRATION_FILE
    end
  end

  private

  def validate_setting_name!(name)
    if !SiteSetting.respond_to?(name)
      say "Site setting with #{name} does not exist"
      raise ArgumentError
    end
  end

  def setting_type(name)
    @site_settings ||= load_settings(File.join(Rails.root, "config", "site_settings.yml"))
    subgroup = @site_settings.values.find { |row| row.keys.include?(name) }
    subgroup[name][:enum]
  end

  def validate_setting_type!(name)
    if !%w[TrustLevelSetting TrustLevelAndStaffSetting].include?(setting_type(name))
      say "Site setting with #{name} must be TrustLevelSetting"
      raise ArgumentError
    end
  end
end
