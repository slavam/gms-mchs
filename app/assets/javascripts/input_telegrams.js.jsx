class NewTelegramForm extends React.Component{
  constructor(props) {
    super(props);
    this.observation = {};
    this.state = {
      currDate:  this.props.currDate,
      tlgType: this.props.tlgType,
      tlgTerm: 0, //this.props.tlgType == 'synoptic' ? this.props.tlgTerm : null,
      tlgText: '',
      errors: this.props.errors
    };
    this.dateChange = this.dateChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleOptionSelected = this.handleOptionSelected.bind(this);
    this.handleTextChange = this.handleTextChange.bind(this);
  }
  handleSubmit(e) {
    e.preventDefault();
    var term = this.state.tlgTerm;
    var text = this.state.tlgText; //.trim();
    var date = this.state.currDate;
    var errors = [];
    
    this.state.errors = [];
    if (!text) {
      this.setState({errors: ["Нет текста телеграммы"]});
      return;
    }
    this.observation.telegram = text;
    switch (this.state.tlgType) {
      case 'synoptic':
        if (!checkTelegram(term, text, errors, this.props.stations, this.observation, this.state)){
          this.setState({errors: errors});
          return;
        }
        this.observation.term = term;
        this.observation.date = date;
        break;
      case 'storm':
        if (!checkStormTelegram(text, this.props.stations, errors, this.observation)){
          this.setState({errors: errors});
          return;
        }
        this.observation.telegram_date = date;
        break;
      case 'agro':
        this.observation.date_dev = date;
      case 'sea':
        this.observation.date_dev = date;
    }
    this.props.onFormSubmit({observation: this.observation, currDate: date, tlgType: this.state.tlgType, tlgText: this.state.tlgText});
    this.setState({
      // tlgTerm: term,
      tlgText: '',
      // errors: []
    });
  }
  dateChange(e){
    this.setState({currDate: e.target.value});
  }
  handleOptionSelected(value, senderName){
    if (senderName == 'selectTypes'){
      this.setState({tlgType:  value});
    }else{
      this.setState({tlgTerm:  value});
    }
  }
  handleTextChange(e) {
    this.setState({tlgText: e.target.value});
  }
  render() {
    const types = [
      { value: 'synoptic', label: 'Синоптические' },
      { value: 'agro', label: 'Агро' },
      { value: 'storm', label: 'Штормовые' },
      { value: 'sea', label: 'Морские' },
    ];
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
    return (
    <div className="col-md-12">
      <form className="telegramForm" onSubmit={this.handleSubmit}>
        <table className="table table-hover">
          <thead>
            <tr>
              <th>Дата</th>
              <th>Тип</th>
              {this.state.tlgType == 'synoptic' ? <th>Срок</th> : <th></th>}
            </tr>
          </thead>
          <tbody>
            <tr>        
              <td><input type="date" name="input-date" value={this.state.currDate} onChange={this.dateChange} required="true" autoComplete="on" /></td>
              <td><OptionSelect options={types} onUserInput={this.handleOptionSelected} name = "selectTypes" defaultValue="synoptic"/></td>
              {this.state.tlgType == 'synoptic' ? <td><OptionSelect options={terms} onUserInput={this.handleOptionSelected} name = "selectTerms" defaultValue="00"/></td> : <td></td>}
            </tr>
          </tbody>
        </table>
        <p>Текст: 
          <input type="text" value={this.state.tlgText} onChange={this.handleTextChange}/>
          <span style={{color: 'red'}}>{this.state.errors[0]}</span>
        </p>
        <input type="submit" value="Сохранить" />
      </form>
    </div>
    );
  }
}

class TelegramRow extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      tlgText: this.props.telegram.telegram,
      tlgId: this.props.telegram.id,
      mode: 'Изменить'
    };
    this.handleEditClick = this.handleEditClick.bind(this);
    this.handleEditTelegramSubmit = this.handleEditTelegramSubmit.bind(this);
  }
  handleEditClick(e){
    if (this.state.mode == 'Изменить') {
      this.setState({mode:'Отменить'});
    } else
      this.setState({mode:'Изменить'});
  }
  handleEditTelegramSubmit(tlgText){
    // var errors = [];
    var observation = {};
    // if (!checkTelegram(this.props.telegram.term, tlgText.tlgText, errors, this.props.stations, observation)){
    //   alert(errors[0]);
    //   this.setState({errors: errors});
    //   return;
    // }
    observation.telegram = tlgText.tlgText;
    this.setState({mode: "Изменить", tlgText: tlgText.tlgText});
    $.ajax({
      type: 'PUT',
      dataType: 'json',
      data: {observation: observation},
      url: "update_synoptic_telegram?id="+this.props.telegram.id+"&telegram="+tlgText.tlgText
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
    var desiredLink = '';
    switch(this.props.tlgType) {
      case 'synoptic':
        desiredLink = "/synoptic_observations/"+this.props.telegram.id;
        break;
      case 'storm':
        desiredLink = "/storm_observations/"+this.props.telegram.id;
        break;
      case 'agro':
        desiredLink = "/agro_observations/"+this.props.telegram.id;
        break;
      case 'sea':
        desiredLink = "/sea_observations/"+this.props.telegram.id;
        break;
    }
    return (
      <tr>
        <td>{this.props.telegram.date}</td>
        { this.props.tlgType == 'synoptic' ? <td>{this.props.telegram.term}</td> : '' }
        <td>{this.props.telegram.station_name}</td>
        {this.state.mode == 'Изменить' ? <td><a href={desiredLink}>{this.state.tlgText}</a></td> : <td><TelegramEditForm tlgText={this.state.tlgText} onTelegramEditSubmit={this.handleEditTelegramSubmit}/></td>}
        {(now - Date.parse(this.props.telegram.date)) > 1000 * 60 * 60 * 24 * 7 ? <td></td> : <td><input id={this.props.telegram.date} type="submit" value={this.state.mode} onClick={this.handleEditClick}/></td>}
      </tr>
    );
  }
}
class LastTelegramsTable extends React.Component{
  constructor(props){
    super(props);
    this.state = {
      tlgType: this.props.tlgType,
    };
  }
  render() {
    var rows = [];
    var that = this;
    this.props.telegrams.forEach(function(t) {
      rows.push(<TelegramRow telegram={t} key={t.id} tlgType={that.props.tlgType}/>);
    });
    return (
      <table className="table table-hover">
        <thead>
          <tr>
            <th>Дата</th>
            { this.props.tlgType == 'synoptic' ? <th>Срок</th> : '' }
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

class InputTelegrams extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      currDate: this.props.currDate,
      tlgType: this.props.tlgType,
      errors: [],
      telegrams: this.props.telegrams
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
    this.handleTelegramTypeChanged = this.handleTelegramTypeChanged.bind(this);
  }

  handleTelegramTypeChanged(){
    var that = this;
    var desiredLink = '';
    $.ajax({
      type: 'GET',
      dataType: 'json',
      // data: tlgData, 
      url: desiredLink
      }).done(function(data) {
        that.setState({telegrams: data.telegrams});
      }.bind(that)).fail(function(res) {
        that.setState({errors: ["Ошибка записи в базу"]});
      }.bind(that)); 
    
  }
  handleFormSubmit(telegram) {
    var that = this;
    var tlgData = {};
    var desiredLink = '';
    switch(telegram.tlgType) {
      case 'synoptic':
        tlgData = {observation: telegram.observation},
        desiredLink = "synoptic_observations/create_synoptic_telegram";
        break;
      case 'agro':
        telegram.observation.date_dev = telegram.observation.date;
        tlgData = {agro_observation: telegram.observation};
        desiredLink = "agro_observations/create_agro_telegram";
        break;
      case 'storm':
        tlgData = {storm_observation: telegram.observation};
        desiredLink = "storm_observations/create_storm_telegram";
        break;
      case 'sea':
        tlgData = {sea_observation: telegram.observation};
        desiredLink = "sea_observations/create_sea_telegram";
    }
    $.ajax({
      type: 'POST',
      dataType: 'json',
      data: tlgData, 
      url: desiredLink
      }).done(function(data) {
        that.setState({telegrams: data.telegrams, tlgType: data.tlgType, currDate: data.currDate, errors: data.errors});
      }.bind(that)).fail(function(res) {
        that.setState({errors: ["Ошибка записи в базу"]});
      }.bind(that)); 
  }

  render(){
    return(
      <div>
        <h1>Новая телеграмма</h1>
        <NewTelegramForm currDate={this.state.currDate} tlgType={this.state.tlgType} onFormSubmit={this.handleFormSubmit} stations={this.props.stations} errors={this.state.errors} />
        <h3>Телеграммы</h3>
        <LastTelegramsTable telegrams={this.state.telegrams} tlgType={this.state.tlgType} />
      </div>
    );
  }
}

function checkStormTelegram(tlg, stations, errors, observation){
  if(~tlg.indexOf("ЩЭОЗМ ") || ~tlg.indexOf("ЩЭОЯЮ ") ){
    observation.telegram_type = tlg.substr(0, 5);
  } else {
    errors.push("Ошибка в различительной группе");
    return false;
  }
  if(~tlg.indexOf(" WAREP ")){} else {
    errors.push("Отсутствует идентификатор WAREP");
    return false;
  }
  var codeStation = tlg.substr(12,5);
  var isStation = false; 
  var idStation = -1;
  isStation = stations.some(function(s){
    idStation = s.id;
    return +codeStation == s.code;
  });
  if (isStation && (tlg[17] == ' ')) {
    observation.station_id = idStation;
  } else {
    errors.push("Ошибка в коде метеостанции");
    return false;
  }
  var value;
  value = tlg.substr(18,2);
  if ((+value > 0) && (+value < 32)){
    observation.day_event = value;
  } else {
    errors.push("Ошибка в номере дня");
    return false;
  }
  value = tlg.substr(20,2);
  if ((+value >= 0) && (+value < 24)){
    observation.hour_event = value;
  } else {
    errors.push("Ошибка в часе явления");
    return false;
  }
  value = tlg.substr(22,2);
  if ((+value >= 0) && (+value < 60)){
    observation.minute_event = value;
  } else {
    errors.push("Ошибка в минутах явления");
    return false;
  }
  if(tlg[24] != '1') {
    errors.push("Ошибка вида телеграммы (a=1)");
    return false;
  }
  
  var codeWAREP = +tlg.substr(26,2);
  var isCodeWAREP;
  isCodeWAREP = [11, 12, 17, 18, 19, 30, 36, 40, 41, 50, 51, 52, 53, 54, 55, 56, 57, 61, 62, 64, 65, 66, 68, 71, 75, 78, 90, 91, 92, 95].some(function(s){
    return codeWAREP == s;
  });
  if (isCodeWAREP) {
    observation.code_warep = value;
  } else {
    errors.push("Ошибочный код WAREP");
    return false;
  }
  var windDirections = Array.from({ length: 37 }, (v, k) => k);
  windDirections.push(99);
  function isGroup1(code, windDirection) {
    if ((code == 17) || (code == 18))
      return (tlg[29] == '1' && windDirections.some(elem => elem == value) && (tlg.substr(32,2) == '//') && (0 < +tlg.substr(34,2) <= 99));
    else
      return (tlg[29] == '1' && windDirections.some(elem => elem == value) && (0 < +tlg.substr(32,2) <= 99) && (0 < +tlg.substr(34,2) <= 99));
  }
  function isGroup2(group2){
    let correctDirection;
    let val = group2.substr(1,2);
    correctDirection = ((val == '//') || windDirections.some(elem => elem == +val));
    val = +group2.substr(3,2);
    let correctPrecipitation = (val == 17) || (val == 19) || (80 <= val <= 90);
    return (group2[0] == '2' && correctDirection && correctPrecipitation);
  }
  switch (codeWAREP) {
    case 11, 12, 17, 18:
      value = +tlg.substr(30,2);
      if (isGroup1(codeWAREP, value)){
        observation.wind_direction = value;
        observation.wind_speed_avg = (codeWAREP == 17 || codeWAREP == 18) ? null : tlg.substr(32,2);
        observation.wind_speed_max = tlg.substr(34,2);
      } else {
        errors.push("Ошибка в группе 1");
        return false;
      }
      break;
    case 19:
      value = +tlg.substr(30,2);
      if (isGroup1(codeWAREP, value)){
        observation.wind_direction = value;
        observation.wind_speed_avg = tlg.substr(32,2);
        observation.wind_speed_max = tlg.substr(34,2);
      } else {
        errors.push("Ошибка в группе 1");
        return false;
      }
      // add group 2
      break;
    case 36, 78:
      value = +tlg.substr(30,2);
      if (isGroup1(codeWAREP, value)){
        observation.wind_direction = value;
        observation.wind_speed_avg = tlg.substr(32,2);
        observation.wind_speed_max = tlg.substr(34,2);
      } else {
        errors.push("Ошибка в группе 1");
        return false;
      }
      // add group 7
      break;
    case 91:
      if(tlg.substr(0, 5) == 'ЩЭОЗМ' && tlg[28] == '=') {return true}
      var group = +tlg.substr(29,5);
      if(isGroup2(group)){
        observation.event_direction = group.substr(1,2) == '//' ? null : group.substr(1,2);
      }
      
      break;      
  }
  // return false; // debug only! 
  return true;
}
function  checkTelegram(term, tlg, errors, stations, observation){
  var state = {
      group00: { errorMessage: 'Ошибка в группе00', regex: /^[134/][1-4][0-9/]([0-4][0-9]|50|5[6-9]|[6-9][0-9]|\/\/)$/ },
      group0: { errorMessage: 'Ошибка в группе0', regex: /^[0-9/]([012][0-9]|3[0-6]|99|\/\/)([012][0-9]|30|\/\/)$/ },
      group1: { errorMessage: 'Ошибка в группе 1 раздела 1', regex: /^1[01][0-5][0-9][0-9]$/ },
      group2: { errorMessage: 'Ошибка в группе 2 раздела 1', regex: /^2[01][0-5][0-9][0-9]$/ },
      group3: { errorMessage: 'Ошибка в группе 3 раздела 1', regex: /^3\d{4}$/ },
      group4: { errorMessage: 'Ошибка в группе 4 раздела 1', regex: /^4\d{4}$/ },
      group5: { errorMessage: 'Ошибка в группе 5 раздела 1', regex: /^5[0-8]\d{3}$/ },
      group6: { errorMessage: 'Ошибка в группе 6 раздела 1', regex: /^6\d{3}[12]$/ }, // From Margo 20170315 
      group7: { errorMessage: 'Ошибка в группе 7 раздела 1', regex: /^7\d{4}$/ },
      group8: { errorMessage: 'Ошибка в группе 8 раздела 1', regex: /^8[0-9/]{4}$/ }, // From Margo 20170317 
      group31: { errorMessage: 'Ошибка в группе 1 раздела 3', regex: /^1[01][0-9]{3}$/ },
      group32: { errorMessage: 'Ошибка в группе 2 раздела 3', regex: /^2[01][0-9]{3}$/ },
      group34: { errorMessage: 'Ошибка в группе 4 раздела 3', regex: /^4[0-9/][0-9]{3}$/ },
      group35: { errorMessage: 'Ошибка в группе 5 раздела 3', regex: /^55[0-9]{3}$/ },
      group38: { errorMessage: 'Ошибка в группе 8 раздела 3', regex: /^8[0-9/]{2}([0-4][0-9]|50|5[6-9]|[6-9][0-9])$/ },
      group39: { errorMessage: 'Ошибка в группе 9 раздела 3', regex: /^9[0-9]{4}$/ },
      group51: { errorMessage: 'Ошибка в группе 1 раздела 5', regex: /^1[0-9/][01][0-9]{2}$/ },
      group53: { errorMessage: 'Ошибка в группе 3 раздела 5', regex: /^3[0-9/][01][0-9]{2}$/ },
      group55: { errorMessage: 'Ошибка в группе 5 раздела 5', regex: /^52[01][0-9]{2}$/ },
      group56: { errorMessage: 'Ошибка в группе 6 раздела 5', regex: /^6[0-9/]{4}$/ },
      group59: { errorMessage: 'Ошибка в группе 9 раздела 5', regex: /^9[0-9/]{4}$/ },
    
  };
  // alert("checkTelegram")
    if((~tlg.indexOf("ЩЭСМЮ ") && (term % 2 == 0)) || (~tlg.indexOf("ЩЭСИД ") && (term % 2 == 1))){} else {
      errors.push("Ошибка в различительной группе");
      return false;
    }
    var group = tlg.substr(6,5);
    var isStation = false; 
    isStation = stations.some(function(s){
      return +group == s.code;
    });
    if (isStation && (tlg[11] == ' ' || tlg[11] == '=')) {
    } else {
      errors.push("Ошибка в коде метеостанции");
      return false;
    }
    
    group = tlg.substr(12,5);
    var regex = '';
    regex = state.group00.regex;
    if (regex.test(group) && ((tlg[17] == ' ') || (tlg[17] == '='))) {
      if(tlg[14] != '/')
        observation.cloud_base_height = tlg[14];
      if(tlg[15] != '/')
        observation.visibility_range = tlg.substr(15,2);
    } else {
      errors.push(state.group00.errorMessage);
      return false;
    }
    
    group = tlg.substr(18,5);
    regex = state.group0.regex;
    if (regex.test(group) && ((tlg[23] == ' ') || (tlg[23] == '='))) {
      if (tlg[18] != '/') {
        observation.cloud_amount_1 = tlg[18];
        observation.wind_direction = tlg.substr(19,2);
        observation.wind_speed_avg = tlg.substr(21,2);
      }
    } else {
      errors.push(state.group0.errorMessage);
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
          regex = state[name].regex;
          if (regex.test(group) && ((section[5] == ' ') || (section[5] == '=') || (section.length == 5))) {
            switch(section[0]) {
              case '1':
              case '3':
                if (section[1] != '/') {
                  if (section[0] == '1') 
                    observation.soil_surface_condition_1 = section[1];
                  else 
                    observation.soil_surface_condition_2 = section[1];
                }
                if (section[2] != '/') {
                  sign = section[2] == '0' ? '' : '-';
                  if (section[0] == '1') 
                    observation.temperature_soil = sign+section.substr(3,2);
                  else 
                    observation.temperature_soil_min = sign+section[3]+'.'+section[4];
                }
                break;
              case '5':
                sign = section[2] == '0' ? '' : '-';
                observation.temperature_2cm_min = section.substr(3,2);
                break;
              case '6':
                observation.precipitation_2 = section.substr(1,3);
                observation.precipitation_time_range_2 = section[4];
                break;
              // case '9':
            }
          } else {
            errors.push(state[name].errorMessage);
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
          regex = state[name].regex;
          if (regex.test(group) && ((section[5] == ' ') || (section[5] == '=') || (section.length == 5))) {
            switch(section[0]) {
              case '1':
              case '2':
                sign = section[1] == '0' ? '' : '-';
                val = sign+section.substr(2,2)+'.'+section[4];
                if (section[0] == '1')
                  observation.temperature_dey_max = val;
                else
                  observation.temperature_night_min = val;
                break;
              case '4':
                if (section[1] != '/') {
                  observation.underlying_surface_сondition = section[1];
                  observation.snow_cover_height = section.substr(2,3);
                }
                break;
              case '5':
                observation.sunshine_duration = section.substr(2,2)+'.'+section[4];
                break;
              case '8':
                if (section[1] != '/') {
                  observation.cloud_amount_3 = section[1];
                  observation.cloud_form = section[2];
                  observation.cloud_height = section.substr(3,2);
                }
                break;
              case '9':
                observation.weather_data_add = section.substr(1,4);
                break;
            }
          } else {
            errors.push(state[name].errorMessage);
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
        regex = state[name].regex;
        if (regex.test(group) && ((section[5] == ' ') || (section[5] == '=') || (section.length == 5))) {
          switch(section[0]) {
            case '1':
            case '2':
              sign = section[1] == '0' ? '' : '-';
              val = sign+section.substr(2,2)+'.'+section[4];
              if (section[0] == '1')
                observation.temperature = val;
              else
                observation.temperature_dew_point = val;
              break;
            case '3':
            case '4':
              first = section[1] == '0' ? '1' : '';
              val = first+section.substr(1,3)+'.'+section[4];
              if (section[0] == '3')
                observation.pressure_at_station_level = val;
              else
                observation.pressure_at_sea_level = val;
              break;
            case '5':
              observation.pressure_tendency_characteristic = section[1];
              observation.pressure_tendency = section.substr(2,2)+'.'+section[4];
              break;
            case '6':
              observation.precipitation_1 = section.substr(1,3);
              observation.precipitation_time_range_1 = section[4];
              break;
            case '7':
              observation.weather_in_term = section.substr(1,2);
              observation.weather_past_1 = section[3];
              observation.weather_past_2 = section[4];
              break;
            case '8':
              if (section[1] != '/') {
                observation.cloud_amount_2 = section[1];
                observation.clouds_1 = section[2];
                observation.clouds_2 = section[3];
                observation.clouds_3 = section[4];
              }
          }
        } else {
          errors.push(state[name].errorMessage);
          return false;
        }
        section = section.substr(6);
      }
    }
    return true;
  }
