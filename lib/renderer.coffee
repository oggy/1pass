util = require 'util'

METADATA = [
  ["Logins", [
    ['webforms.WebForm', "Login", [
    ]]
  ]]

  ["Accounts", [
    ['wallet.onlineservices.AmazonS3', "Amazon Web Service", [
      ['path', "Path"]
      ['email', "Email"]
      ['password', "Password"]
      ['access_key_id', "Access Key Id"]
      ['access_key', "Secret Access Key"]
    ]]
    ['wallet.computer.Database', "Database", [
      ['database_type', "Type"]
      null
      ['hostname', "Server"]
      ['port', "Port"]
      ['database', "Database"]
      ['username', "Username"]
      ['password', "Password"]
      null
      ['sid', "SID"]
      ['alias', "Alias"]
      ['options', "Connection Options"]
    ]]
    ['wallet.onlineservices.Email.v2', "Email Account", [
      ['pop_type', "Type"]
      ['pop_username', "Username"]
      ['pop_server', "Server"]
      ['pop_port', "Port Number"]
      ['pop_password', "Password"]
      ['pop_security', "Security"]
      ['pop_authentication', "Authentication Method"]
      null
      ['smtp_server', "SMTP Server"]
      ['smtp_port', "Port Number"]
      ['smtp_username', "Username"]
      ['smtp_password', "Password"]
      ['smtp_security', "Security"]
      ['smtp_authentication', "Authentication Method"]
      null
      ['provider', "Provider"]
      ['provider_website', "Provider's Website"]
      ['phone_local', "Phone Number (Local)"]
      ['phone_tollfree', "Phone Number (Toll Free)"]
    ]]
    ['wallet.onlineservices.FTP', "FTP Account", [
      ['server', "Server"]
      ['path', "Path"]
      ['username', "User Name"]
      ['password', "Password"]
      null
      ['provider', "Provider"]
      ['provider_website', "Provider's Website"]
      ['phone_local', "Phone Number (Local)"]
      ['phone_tollfree', "Phone Number (Toll Free)"]
    ]]
    ['wallet.onlineservices.GenericAccount', "Generic Account", [
      ['username', "Username"]
      ['password', "Password"]
    ]]
    ['wallet.onlineservices.InstantMessenger', "Instant Messenger", [
      ['account_type', "Account Type"]
      ['username', "User Name / Email / ID"]
      ['password', "Password"]
      ['server', "Server"]
      ['port', "Port"]
    ]]
    ['wallet.onlineservices.ISP', "Internet Provider", [
      ['userid', "User ID"]
      ['password', "Password"]
      ['pin', "PIN"]
      ['dialup_number', "Dialup Access Number"]
      null
      ['website', "Website"]
      ['phone_local', "Phone (Local)"]
      ['phone_tollfree', "Phone (Toll Free)"]
    ]]
    ['wallet.onlineservices.DotMac', "MobileMe", [
      ['email', "Apple ID (email)"]
      ['member_name', "Member"]
      ['password', "Password"]
      ['idisk_storage', "Available iDisk Storage"]
      ['renewal_date', "Renewal Date", 'date']
      ['activation_key', "Activation Key"]
    ]]
    ['wallet.computer.UnixServer', "Server", [
      ['url', "URL"]
      ['username', "Username"]
      ['password', "Password"]
      null
      ['admin_console_url', "Admin Console URL"]
      ['admin_console_username', "Admin Console Username"]
      ['admin_console_password', "Console Password"]
      null
      ['name', "Name"]
      ['website', "Website"]
      ['support_contact_url', "Support URL"]
      ['support_contact_phone', "Support Phone #"]
    ]]
    ['wallet.computer.Router', "Wireless Router", [
      ['name', "Base Station Name"]
      ['password', "Base Station Password"]
      ['server', "Server / IP Address"]
      ['airport_id', "AirPort ID"]
      ['network_name', "Network Name"]
      ['wireless_security', "Wireless Security"]
      ['wireless_password', "Wireless Network Password"]
      ['disk_password', "Attached Storage Password"]
    ]]
    ['wallet.onlineservices.iTunes', "iTunes", [
      ['username', "Apple ID (email)"]
      ['password', "Password"]
      ['question', "Security Question"]
      ['answer', "Security Answer"]
    ]]
  ]]

  ["Identities", [
    ['identities.Identity', "Identity", [
      ['firstname', "First Name"]
      ['initial', "Initial"]
      ['lastname', "Last Name"]
      ['sex', "Sex"]
      ['birthdate', "Birth Date", 'date']
      ['occupation', "Occupation"]
      ['company', "Company"]
      ['department', "Department"]
      ['jobtitle', "Job Title"]
      null
      ['country', "Country"]
      ['state', "State/Province"]
      ['address1', "Address Line 1"]
      ['address2', "Address Line 2"]
      ['city', "City/Town/Suburb"]
      ['zip', "Zip/Postal Code"]
      null
      ['defphone_local', "DefaultPhone"]
      ['homephone_local', "Home"]
      ['cellphone_local', "Cell"]
      ['busphone_local', "Business"]
      null
      ['username', "Username"]
      ['reminderq', "Reminder Question"]
      ['remindera', "Reminder Answer"]
      ['email', "Email"]
      ['website', "Website"]
      ['icq', "ICQ"]
      ['skype', "Skype"]
      ['aim', "AOL/AIM"]
      ['yahoo', "Yahoo"]
      ['msn', "MSN"]
      ['forumsig', "Forum Signature"]
    ]]
  ]]

  ["Secure Notes", [
    ['securenotes.SecureNote', "Secure Note", [
    ]]
  ]]

  ["Software", [
    ['wallet.computer.License', "Software", [
      ['reg_code', "License Key"]
      null
      ['reg_name', "Licensed To"]
      ['reg_email', "Registered Email"]
      ['company', "Company"]
      ['download_link', "Download Page"]
      null
      ['publisher_name', "Publisher"]
      ['publisher_website', "Website"]
      ['retail_price', "Retail Price"]
      ['support_email', "Support Email"]
      null
      ['order_date', "Purchase Date", 'date']
      ['order_number', "Order Number"]
      ['order_total', "Order Total"]
    ]]
  ]]

  ["Wallet", [
    ['wallet.financial.BankAccountUS', "Bank Account", [
      ['bankName', "Bank Name"]
      ['owner', "Name on Account"]
      ['accountType', "Type"]
      ['routingNo', "Routing Number"]
      ['accountNo', "Account Number"]
      ['swift', "SWIFT Code"]
      ['iban', "IBAN Number"]
      ['telephonePin', "PIN"]
      null
      ['branchPhone', "Phone"]
      ['branchAddress', "Address"]
    ]]
    ['wallet.financial.CreditCard', "Credit Card", [
      ['cardholder', "Cardholder's Name"]
      ['type', "Type"]
      ['ccnum', "Number"]
      ['cvv', "Verification Number"]
      ['expiry', "Expiry Date", 'month']
      ['validFrom', "Valid From", 'month']
      null
      ['bank', "Issuing Bank"]
      ['phoneLocal', "Phone (Local)"]
      ['phoneTollFree', "Phone (Toll Free)"]
      ['phoneIntl', "Phone (International)"]
      ['website', "Website"]
      null
      ['pin', "PIN"]
      ['creditLimit', "Credit Limit"]
      ['cashLimit', "Cash Withdrawal Limit"]
      ['interest', "Interest Rate"]
      ['issuenumber', "Issue Number"]
    ]]
    ['wallet.government.DriversLicense', "Driver's License", [
      ['fullname', "Full Name"]
      ['address', "Address"]
      ['birthdate', "Date of Birth", 'date']
      ['sex', "Sex"]
      ['height', "Height"]
      ['number', "Number"]
      ['class', "License Class"]
      ['conditions', "Conditions / Restrictions"]
      ['state', "State"]
      ['country', "Country"]
      ['expiry_date', "Expiry Date", 'month']
    ]]
    ['wallet.government.HuntingLicense', "Hunting License", [
      ['name', "Full Name"]
      ['valid_from', "Valid From", 'date']
      ['expires', "Expires", 'date']
      ['game', "Approved Wildlife"]
      ['quota', "Maximum Quota"]
      ['state', "State"]
      ['country', "Country"]
    ]]
    ['wallet.membership.Membership', "Membership", [
      ['org_name', "Organization"]
      ['website', "Website"]
      ['phone', "Telephone"]
      ['member_name', "Member Name"]
      ['member_since', "Member Since", 'month']
      ['expiry_date', "Expiry Date", 'month']
      ['membership_no', "Membership #"]
      ['pin', "Password"]
    ]]
    ['wallet.government.Passport', "Passport", [
      ['type', "Type"]
      ['issuing_country', "Issuing Country"]
      ['number', "Number"]
      ['fullname', "Full Name"]
      ['sex', "Sex"]
      ['nationality', "Nationality"]
      ['issuing_authority', "Issuing Authority"]
      ['birthdate', "Date of Birth", 'date']
      ['birthplace', "Place of Birth"]
      ['issue_date', "Issued On", 'date']
      ['expiry_date', "Expiry Date", 'date']
    ]]
    ['wallet.membership.RewardProgram', "Reward Program", [
      ['company_name', "Company Name"]
      ['member_name', "Member Name"]
      ['membership_no', "Membership #"]
      ['pin', "PIN"]
      null
      ['membership_no', "Membership # (Additional)"]
      ['member_since', "Member Since", 'month']
      ['customer_service_phone', "Customer Service Phone"]
      ['reservations_phone', "Reservations Phone"]
      ['website', "Website"]
    ]]
    ['wallet.government.SsnUS', "Social Security Number", [
      ['name', "Name"]
      ['number', "Number"]
    ]]
  ]]

  ["Generated Passwords", [
    ['passwords.Password', "Password", [
      ['password', "Password"]
    ]]
  ]]
]

TYPE_TO_METADATA = {}
for section in METADATA
  [sectionName, sectionData] = section
  for sectionDataItem in sectionData
    [type, typeDescription, metadata] = sectionDataItem
    TYPE_TO_METADATA[type] = [typeDescription, metadata]

class Renderer
  constructor: (@item) ->
    if typeDescriptionAndMetadata = TYPE_TO_METADATA[@item.type]
      [@typeDescription, @metadata] = typeDescriptionAndMetadata

  render: (stream) ->
    if !@metadata
      stream.write "Unknown item type: #{@item.type} - raw item data is below.\n"
      stream.write "Please file a bug report at https://github.com/oggy/1pass/issues containing\n"
      stream.write "this data, masking any sensitive information. Thanks!\n"
      @renderRaw(stream)
    else
      @renderTitle(stream)
      if @item.type == 'webforms.WebForm'
        @renderFields(stream)
      else
        @renderDetail(stream)
      @renderNotes(stream)

  renderRaw: (stream) ->
    stream.write(util.inspect(@item, false, null).replace(/(^|\n)/g, '$1  ') + "\n")

  renderTitle: (stream) ->
    stream.write("#{@item.name} (#{@typeDescription})")
    if location = @item.detail().location
      stream.write("  #{location}")
    stream.write('\n')

  renderFields: (stream) ->
    for field in @item.decrypted.fields
      continue if !field.name and !field.value
      stream.write("  #{field.name ? ''}: #{field.value ? ''}\n")

  renderDetail: (stream) ->
    data = @item.decrypted
    for item in @metadata
      if item
        [key, description, type] = item
        switch type
          when 'date'
            yy = data[key + '_yy']
            mm = data[key + '_mm']; mm = '0' + mm if parseInt(mm, 10) < 10
            dd = data[key + '_dd']; dd = '0' + dd if parseInt(dd, 10) < 10
            value = "#{yy}-#{mm}-#{dd}"
          when 'month'
            yy = data[key + '_yy']
            mm = data[key + '_mm']; mm = '0' + mm if parseInt(mm, 10) < 10
            value = "#{yy}-#{mm}"
          else
            value = data[key]
        if value
          stream.write("  #{description}: #{value}\n")
      else
        stream.write("\n")

  renderNotes: (stream) ->
    if notes = @item.decrypted.notesPlain
      indentedNotes = notes.replace(/(^|\n)/g, '    ')
      stream.write("\n  Notes:\n#{indentedNotes}\n")

module.exports = Renderer
