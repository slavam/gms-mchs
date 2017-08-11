class InputError extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      message: 'Input is invalid'
    };
  }
  render(){ 
    var errorClass = classNames(this.props.className, {
      'error_container':   true,
      'visible':           this.props.visible,
      'invisible':         !this.props.visible
    });
    return (
      <div className={errorClass}>
        <span>{this.props.errorMessage}</span>
      </div>
    );
  }
}

class TlgOptionSelect extends React.Component{
  constructor(props) {
    super(props);
    this.handleOptionChange = this.handleOptionChange.bind(this);
  }
  handleOptionChange(event) {
    this.props.onUserInput(event.target.value, event.target.name);
  }
  render(){
    return <select name={this.props.name} onChange={this.handleOptionChange} defaultValue = {this.props.defaultValue}>
      {
        this.props.options.map(function(op) {
          return <option key={op.code} value={op.code}>{op.name}</option>;
        })
      }
    </select>;
  }
}

class SynopticTelegramForm extends React.Component{
  constructor(props) {
    super(props);
    var today = new Date();
    this.observation = {
      date: today.toISOString().substr(0, 10),
      cloud_base_height: null,
      visibility_range: null,
      cloud_amount_1: null,
    };
    this.stations = this.props.stations;
    this.state = {
      tlgTerm: '00',
      tlgHeader: this.props.tlgHeader,
      stationIndex: '34622',
      group00: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе00', regex: /^[134/][1-4][0-9/]([0-4][0-9]|50|5[6-9]|[6-9][0-9]|\/\/)$/ },
      group0: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе0', regex: /^[0-9/]([012][0-9]|3[0-6]|99|\/\/)([012][0-9]|30|\/\/)$/ },
      group1: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 1 раздела 1', regex: /^1[01][0-5][0-9][0-9]$/ },
      group2: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 2 раздела 1', regex: /^2[01][0-5][0-9][0-9]$/ },
      group3: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 3 раздела 1', regex: /^3\d{4}$/ },
      group4: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 4 раздела 1', regex: /^4\d{4}$/ },
      group5: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 5 раздела 1', regex: /^5[0-8]\d{3}$/ },
      group6: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 6 раздела 1', regex: /^6\d{3}[12]$/ }, // From Margo 20170315 
      group7: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 7 раздела 1', regex: /^7\d{4}$/ },
      group8: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 8 раздела 1', regex: /^8[0-9/]{4}$/ }, // From Margo 20170317 
      group31: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 1 раздела 3', regex: /^1[01][0-9]{3}$/ },
      group32: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 2 раздела 3', regex: /^2[01][0-9]{3}$/ },
      group34: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 4 раздела 3', regex: /^4[0-9/][0-9]{3}$/ },
      group35: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 5 раздела 3', regex: /^55[0-9]{3}$/ },
      group38: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 8 раздела 3', regex: /^8[0-9/]{2}([0-4][0-9]|50|5[6-9]|[6-9][0-9])$/ },
      group39: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 9 раздела 3', regex: /^9[0-9]{4}$/ },
      group51: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 1 раздела 5', regex: /^1[0-9/][01][0-9]{2}$/ },
      group53: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 3 раздела 5', regex: /^3[0-9/][01][0-9]{2}$/ },
      group55: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 5 раздела 5', regex: /^52[01][0-9]{2}$/ },
      group56: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 6 раздела 5', regex: /^6[0-9/]{4}$/ },
      group59: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 9 раздела 5', regex: /^9[0-9/]{4}$/ },
      tlgText: this.props.tlgHeader+' 34622 =',
      date: today.toISOString().substr(0, 10),
      errors: this.props.errors
    };
    this.row1 = ['group00', 'group0', 'group1', 'group2', 'group3', 'group4', 'group5', 'group6', 'group7', 'group8'];
    this.row3 = ['group31', 'group32', 'group34', 'group35', 'group38', 'group39'];
    this.row5 = ['group51', 'group53', 'group55', 'group56', 'group59'];
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleTextChange = this.handleTextChange.bind(this);
    this.handleOptionSelected = this.handleOptionSelected.bind(this);
    this.makeText = this.makeText.bind(this);
    this.handleGroup00Change = this.handleGroup00Change.bind(this);
    this.checkTelegram = this.checkTelegram.bind(this);
    this.needSection = this.needSection.bind(this);
    this.makeSection = this.makeSection.bind(this);
    this.dateChange = this.dateChange.bind(this);
  }
  needSection(groups) {
    let self = this;
    let isGroups = false;
    isGroups = groups.some(function(g){
      return self.state[g].value.length>0;
    });
    return isGroups;
  }
  makeSection(section, groups){
    let self = this;
    groups.forEach(function(val) {
        section += (self.state[val].value.length>0 ? ' '+self.state[val].value : '');
    });
    return section;
  }
  makeText(){
    let section1 = '';
    let section3 = '';
    let section5 = '';
    if(this.needSection(this.row3)){
      section3 = ' 333'+this.makeSection(section3, this.row3);
    }
    if(this.needSection(this.row5)){
      section5 = ' 555'+this.makeSection(section5, this.row5);
    }
    section1 = this.makeSection(section1, this.row1);
    this.setState({tlgText: this.state.tlgHeader+' '+this.state.stationIndex+section1+section3+section5+'='});
  }
  handleOptionSelected(value, senderName){
    if (senderName == 'selectStation'){
      this.state.stationIndex = value;
    }else{
      this.state.tlgTerm = value;
      this.state.tlgHeader = (+value % 2 == 0) ? "ЩЭСМЮ" : "ЩЭСИД";
    }
    this.makeText();
  }
  handleTextChange(e) {
    this.setState({tlgText: e.target.value});
  }
  checkTelegram(term, tlg, errors){
    if((~tlg.indexOf("ЩЭСМЮ ") && (term % 2 == 0)) || (~tlg.indexOf("ЩЭСИД ") && (term % 2 == 1))){} else {
      errors.push("Ошибка в различительной группе");
      return false;
    }
    var group = tlg.substr(6,5);
    var isStation = false; 
    isStation = this.stations.some(function(s){
        return +group == s.code;
    });
    if (isStation && (tlg[11] == ' ' || tlg[11] == '=')) {} else {
      errors.push("Ошибка в коде метеостанции");
      return false;
    }
    
    group = tlg.substr(12,5);
    var regex = '';
    regex = this.state.group00.regex;
    if (regex.test(group) && ((tlg[17] == ' ') || (tlg[17] == '='))) {
      if(tlg[14] != '/')
        this.observation.cloud_base_height = tlg[14];
      if(tlg[15] != '/')
        this.observation.visibility_range = tlg.substr(15,2);
    } else {
      errors.push(this.state.group00.errorMessage);
      return false;
    }
    
    group = tlg.substr(18,5);
    regex = this.state.group0.regex;
    if (regex.test(group) && ((tlg[23] == ' ') || (tlg[23] == '='))) {
      if (tlg[18] != '/') {
        this.observation.cloud_amount_1 = tlg[18];
        this.observation.wind_direction = tlg.substr(19,2);
        this.observation.wind_speed_avg = tlg.substr(21,2);
      }
    } else {
      errors.push(this.state.group0.errorMessage);
      return false;
    }
    var section = '';
    var pos555 = -1;
    if(~tlg.indexOf(" 555 ")){
      pos555 = tlg.indexOf(" 555 ");
      section = tlg.substr(pos555+5, tlg.length-pos555-5-1);
      if(section.length<5){
        errors.push("Ошибка в разделе 5");
        return false;
      }
      while (section.length>=5) {
        if(~['1', '3', '5', '6', '9'].indexOf(section[0])){
          group = section.substr(0,5);
          var name = 'group5'+section[0];
          regex = this.state[name].regex;
          if (regex.test(group) && ((section[5] == ' ') || (section[5] == '=') || (section.length == 5))) {
            switch(section[0]) {
              case '1':
              case '3':
                if (section[1] != '/') {
                  if (section[0] == '1') 
                    this.observation.soil_surface_condition_1 = section[1];
                  else 
                    this.observation.soil_surface_condition_2 = section[1];
                }
                if (section[2] != '/') {
                  sign = section[2] == '0' ? '' : '-';
                  if (section[0] == '1') 
                    this.observation.temperature_soil = sign+section.substr(3,2);
                  else 
                    this.observation.temperature_soil_min = sign+section[3]+'.'+section[4];
                }
                break;
              case '5':
                sign = section[2] == '0' ? '' : '-';
                this.observation.temperature_2cm_min = section.substr(3,2);
                break;
              case '6':
                this.observation.precipitation_2 = section.substr(1,3);
                this.observation.precipitation_time_range_2 = section[4];
                break;
              // case '9':
            }
          } else {
            errors.push(this.state[name].errorMessage);
            return false;
          }
          section = section.substr(6);
        }
      }
    }

    section = '';
    var pos333 = -1;
    if(~tlg.indexOf(" 333 ")){
      pos333 = tlg.indexOf(" 333 ");
      section = tlg.substr(pos333+5, (pos555>0 ? pos555-pos333-5 : tlg.length-pos333-5-1));
      if(section.length<5){
        errors.push("Ошибка в разделе 3");
        return false;
      }
      while (section.length>=5) {
        if(~['1', '2', '4', '5', '8', '9'].indexOf(section[0])){
          group = section.substr(0,5);
          name = 'group3'+section[0];
          regex = this.state[name].regex;
          if (regex.test(group) && ((section[5] == ' ') || (section[5] == '=') || (section.length == 5))) {
            switch(section[0]) {
              case '1':
              case '2':
                sign = section[1] == '0' ? '' : '-';
                val = sign+section.substr(2,2)+'.'+section[4];
                if (section[0] == '1')
                  this.observation.temperature_dey_max = val;
                else
                  this.observation.temperature_night_min = val;
                break;
              case '4':
                if (section[1] != '/') {
                  this.observation.underlying_surface_сondition = section[1];
                  this.observation.snow_cover_height = section.substr(2,3);
                }
                break;
              case '5':
                this.observation.sunshine_duration = section.substr(2,2)+'.'+section[4];
                break;
              case '8':
                if (section[1] != '/') {
                  this.observation.cloud_amount_3 = section[1];
                  this.observation.cloud_form = section[2];
                  this.observation.cloud_height = section.substr(3,2);
                }
                break;
              case '9':
                this.observation.weather_data_add = section.substr(1,4);
                break;
            }
          } else {
            errors.push(this.state[name].errorMessage);
            return false;
          }
          section = section.substr(6);
        }
      }
    }
    
    var lng = pos333>0 ? pos333-24 : (pos555>0 ? pos555-24 : tlg.length-24);
    section = tlg.substr(24, lng);
    if(section.length<5){
      errors.push("Ошибка в разделе 1");
      return false;
    }
    var sign = '';
    var val = '';
    var first = '';
    while (section.length>=5) {
      if(~['1', '2', '3', '4', '5', '6', '7', '8'].indexOf(section[0])){
        group = section.substr(0,5);
        name = 'group'+section[0];
        regex = this.state[name].regex;
        if (regex.test(group) && ((section[5] == ' ') || (section[5] == '=') || (section.length == 5))) {
          switch(section[0]) {
            case '1':
            case '2':
              sign = section[1] == '0' ? '' : '-';
              val = sign+section.substr(2,2)+'.'+section[4];
              if (section[0] == '1')
                this.observation.temperature = val;
              else
                this.observation.temperature_dew_point = val;
              break;
            case '3':
            case '4':
              first = section[1] == '0' ? '1' : '';
              val = first+section.substr(1,3)+'.'+section[4];
              if (section[0] == '3')
                this.observation.pressure_at_station_level = val;
              else
                this.observation.pressure_at_sea_level = val;
              break;
            case '5':
              this.observation.pressure_tendency_characteristic = section[1];
              this.observation.pressure_tendency = section.substr(2,2)+'.'+section[4];
              break;
            case '6':
              this.observation.precipitation_1 = section.substr(1,3);
              this.observation.precipitation_time_range_1 = section[4];
              break;
            case '7':
              this.observation.weather_in_term = section.substr(1,2);
              this.observation.weather_past_1 = section[3];
              this.observation.weather_past_2 = section[4];
              break;
            case '8':
              if (section[1] != '/') {
                this.observation.cloud_amount_2 = section[1];
                this.observation.clouds_1 = section[2];
                this.observation.clouds_2 = section[3];
                this.observation.clouds_3 = section[4];
              }
          }
        } else {
          errors.push(this.state[name].errorMessage);
          return false;
        }
        section = section.substr(6);
      }
    }
    return true;
  }
  handleSubmit(e) {
    e.preventDefault();
    var term = this.state.tlgTerm.trim();
    var text = this.state.tlgText.trim();
    var errors = [];
    
    if (!term || !text) {
      return;
    }
    if (!this.checkTelegram(term, text, errors)){
      this.setState({errors: errors});
      return;
    }
    // this.props.onTelegramSubmit({date: this.state.date, term: term, stationIndex: this.state.stationIndex, telegram: text, observation: this.observation});
    this.observation.date = this.state.date;
    this.observation.term = term;
    this.observation.telegram = text;
    this.props.onTelegramSubmit({observation: this.observation, stationIndex: this.state.stationIndex});
    this.setState({
      tlgTerm: term,
      tlgHeader: this.props.tlgHeader,
      stationIndex: text.substr(6,5),
      group00: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе00', regex: /^[134/][1-4][0-9/]([0-4][0-9]|50|5[6-9]|[6-9][0-9]|\/\/)$/ },
      group0: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе0', regex: /^[0-9/]([012][0-9]|3[0-6]|99|\/\/)([012][0-9]|30|\/\/)$/ },
      group1: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 1 раздела 1', regex: /^1[01][0-5][0-9][0-9]$/ },
      group2: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 2 раздела 1', regex: /^2[01][0-5][0-9][0-9]$/ },
      group3: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 3 раздела 1', regex: /^3\d{4}$/ },
      group4: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 4 раздела 1', regex: /^4\d{4}$/ },
      group5: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 5 раздела 1', regex: /^5[0-8]\d{3}$/ },
      group6: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 6 раздела 1', regex: /^6\d{3}[12]$/ }, // From Margo 20170315 
      group7: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 7 раздела 1', regex: /^7\d{4}$/ },
      group8: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 8 раздела 1', regex: /^8[0-9/]{4}$/ }, // From Margo 20170317 
      group31: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 1 раздела 3', regex: /^1[01][0-9]{3}$/ },
      group32: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 2 раздела 3', regex: /^2[01][0-9]{3}$/ },
      group34: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 4 раздела 3', regex: /^4[0-9/][0-9]{3}$/ },
      group35: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 5 раздела 3', regex: /^55[0-9]{3}$/ },
      group38: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 8 раздела 3', regex: /^8[0-9/]{2}([0-4][0-9]|50|5[6-9]|[6-9][0-9])$/ },
      group39: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 9 раздела 3', regex: /^9[0-9]{4}$/ },
      group51: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 1 раздела 5', regex: /^1[0-9/][01][0-9]{2}$/ },
      group53: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 3 раздела 5', regex: /^3[0-9/][01][0-9]{2}$/ },
      group55: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 5 раздела 5', regex: /^52[01][0-9]{2}$/ },
      group56: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 6 раздела 5', regex: /^6[0-9/]{4}$/ },
      group59: {value:'', errorVisible: false, errorMessage: 'Ошибка в группе 9 раздела 5', regex: /^9[0-9/]{4}$/ },
      tlgText: text.substr(0,11)+' =',
      errors: []});
  }
  handleGroup00Change(e){
    var group = e.target.value;
    var regex = '';
    this.state[e.target.name].value = e.target.value;
    this.makeText();
    if(group.length<5){
      this.state[e.target.name].errorVisible = false;
      return;
    } 
    regex = this.state[e.target.name].regex;
    if (!regex.test(group)) 
      this.state[e.target.name].errorVisible = true;
    else
      this.state[e.target.name].errorVisible = false;
  }
  dateChange(e){
    // this.state.date = e.target.value;
    this.setState({date: e.target.value});
  }
  render() {
    const terms = [
      { value: '00', label: '00' },
      { value: '03', label: '03' },
      { value: '06', label: '06' },
      { value: '09', label: '09' },
      { value: '12', label: '12' },
      { value: '15', label: '15' },
      { value: '18', label: '18' },
      { value: '21', label: '21' }
    ];
    var self = this;
    return (
      <form className="telegramForm" onSubmit={this.handleSubmit}>
        <table className="table table-hover">
          <thead>
            <tr>
              <th>Дата</th>
              <th>Срок</th>
              <th>Метеостанция</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><input type="date" name="input-date" value={this.state.date} onChange={this.dateChange} required="true" autoComplete="on" /></td>
              <td><OptionSelect options={terms} onUserInput={this.handleOptionSelected} name = "selectTerms" defaultValue="00"/></td>
              <td><TlgOptionSelect options={this.stations} onUserInput={this.handleOptionSelected} name="selectStation" key="selectStation" /></td>
{/*              <td><OptionSelect options={this.stations} onUserInput={this.handleOptionSelected} name="selectStation" key="selectStation" /></td> */}
            </tr>
          </tbody>
        </table>
        <p>
          <span style={{color: 'red'}}>{this.props.errors.terms}</span>
        </p>
        <table className="table table-hover">
          <thead>
            <tr>
              <th>Метеостанция</th>
              <th>Группа00</th>
              <th>Группа0</th>
              <th>Группа1</th>
              <th>Группа2</th>
              <th>Группа3</th>
              <th>Группа4</th>
              <th>Группа5</th>
              <th>Группа6</th>
              <th>Группа7</th>
              <th>Группа8</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                {this.state.stationIndex}
              </td>
              {self.row1.map(function(td) {
                return(<td key={td}>
                  <input type="text" value={self.state[td].value} onChange={self.handleGroup00Change} name={td} />
                  <InputError visible={self.state[td].errorVisible} errorMessage="Ошибка!" />
                </td>);
              })}
            </tr>
          </tbody>
          <thead>
            <tr>
              <th>Раздел 3</th>
              <th>Група1</th>
              <th>Группа2</th>
              <th>Группа4</th>
              <th>Группа5</th>
              <th>Группа8</th>
              <th>Группа9</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                333
              </td>
              {self.row3.map(function(td) {
                return(<td key={td}>
                  <input type="text" value={self.state[td].value} onChange={self.handleGroup00Change} name={td} />
                  <InputError visible={self.state[td].errorVisible} errorMessage="Ошибка!" />
                </td>);
              })}
            </tr>
          </tbody>
          <thead>
            <tr>
              <th>Раздел 5</th>
              <th>Группа1</th>
              <th>Группа3</th>
              <th>Группа5</th>
              <th>Группа6</th>
              <th>Группа9</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                555
              </td>
              {self.row5.map(function(td) {
                return(<td key={td}>
                  <input type="text" value={self.state[td].value} onChange={self.handleGroup00Change} name={td} />
                  <InputError visible={self.state[td].errorVisible} errorMessage="Ошибка!" />
                </td>);
              })}
            </tr>
          </tbody>
        </table>
        
        <p>Текст: 
          <input type="text" value={this.state.tlgText} onChange={this.handleTextChange}/>
          <span style={{color: 'red'}}>{this.state.errors[0]}</span>
        </p>
        <input type="submit" value="Сохранить" />
      </form>
    );
  }
}
class TelegramEditForm extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      tlgText: this.props.tlgText
    };
    this.handleTextChange = this.handleTextChange.bind(this);
    this.handleEditSubmit = this.handleEditSubmit.bind(this);
  }
  handleTextChange(e) {
    this.setState({tlgText: e.target.value});
  }
  handleEditSubmit(e){
    e.preventDefault();
    this.props.onTelegramEditSubmit({tlgText: this.state.tlgText});
  }
  
  render() {
    return (
      <form className="telegramEditForm" onSubmit={this.handleEditSubmit}>
        <input
          type="text"
          size="100"
          value={this.state.tlgText}
          onChange={this.handleTextChange}
        />
        <input type="submit" value="Сохранить" />
      </form>
    );
  }
}
class Telegram extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      tlgText: this.props.telegram.telegram,
      mode: 'Изменить'
    };
    this.handleEditClick = this.handleEditClick.bind(this);
    this.handleEditFormSubmit = this.handleEditFormSubmit.bind(this);
  }
  handleEditClick(e){
    if (this.state.mode == 'Изменить')
      this.setState({mode:'Отменить'});
    else
      this.setState({mode:'Изменить'});
  }
  handleEditFormSubmit(tlgText){
    this.setState({mode: "Изменить", tlgText: tlgText.tlgText});
    $.ajax({
      type: 'GET',
      dataType: 'json',
      url: "update_synoptic_telegram?t_date="+this.props.telegram.date+"&t_text="+tlgText.tlgText
      }).done(function(data) {
        // alert(data["Дата"])
        // newTelegrams[0]["Дата"] = data["Дата"];
        // this.setState({telegrams: newTelegrams});
      }.bind(this))
      .fail(function(jqXhr) {
        console.log('failed to register');
      });
  }
  render() {
    var now = Date.now();
    var desiredLink = "/synoptic_observations/"+this.props.telegram.id;
    return (
      <tr>
        <td>{this.props.telegram.date}</td>
        <td>{this.props.telegram.term}</td>
        <td>{this.props.telegram.station_name}</td>
        {this.state.mode == 'Изменить' ? <td><a href={desiredLink}>{this.state.tlgText}</a></td> : <td><TelegramEditForm tlgText={this.state.tlgText} onTelegramEditSubmit={this.handleEditFormSubmit}/></td>}
        {(now - Date.parse(this.props.telegram.date)) > 1000 * 60 * 60 * 24 * 7 ? <td></td> : <td><input id={this.props.telegram.date} type="submit" value={this.state.mode} onClick={this.handleEditClick}/></td>}
      </tr>
    );
  }
}
class SynopticTelegramsTable extends React.Component{
  render() {
    var rows = [];
    this.props.telegrams.forEach(function(t) {
      rows.push(<Telegram telegram={t} key={t.id} />);
    });
    return (
      <table className="table table-hover">
        <thead>
          <tr>
            <th>Дата</th>
            <th>Срок</th>
            <th>Метеостанция</th>
            <th>Текст</th>
            <th>Действия</th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    );
  }
}

class SynopticTelegram extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      telegrams: this.props.telegrams,
      errors: {}
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
  }

  handleFormSubmit(telegram) {
    var that = this;
    $.ajax({
      type: 'POST',
      dataType: 'json',
      data: {observation: telegram.observation},
      url: "create_synoptic_telegram?station_code="+telegram.stationIndex
      }).done(function(data) {
        that.setState({telegrams: data.telegrams, errors: {}});
      }.bind(that))
      .fail(function(res) {
        that.setState({errors: ["Ошибка записи в базу"]});
      }.bind(that)); 
  }
  
  render(){
    return(
      <div>
        <h3>Создать/изменить телеграмму</h3>
        <SynopticTelegramForm onTelegramSubmit={this.handleFormSubmit} tlgHeader = {'ЩЭСМЮ'} errors = {this.state.errors} stations = {this.props.stations} />
        <h3>Телеграммы</h3>
        <SynopticTelegramsTable telegrams={this.state.telegrams} />
      </div>
    );
  }
}