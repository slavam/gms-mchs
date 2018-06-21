class NewTelegramForm extends React.Component{
  constructor(props) {
    super(props);
    this.observation = {};
    this.state = {
      currDate:  this.props.currDate,
      tlgType: this.props.tlgType,
      tlgTerm: this.props.term,  
      tlgText: '',
      errors: [] 
    };
    this.handleOptionSelected = this.handleOptionSelected.bind(this);
    this.dateChange = this.dateChange.bind(this);
    this.inBufferClick = this.inBufferClick.bind(this);
  }
  
  handleSubmit(e) {
    e.preventDefault();
    if(this.props.inputMode == 'normal'){
      let d = new Date();
      this.state.currDate = d.getUTCFullYear()+'-'+('0'+(d.getUTCMonth()+1)).slice(-2)+'-'+('0'+d.getUTCDate()).slice(-2);
      if (this.state.tlgType == 'synoptic'){  // mwm 20180619
        let t = Math.floor(d.getUTCHours() / 3) * 3;
        this.state.tlgTerm = t < 10 ? '0'+t : t;
      }
    }
    var term = this.state.tlgTerm;
    var text = this.state.tlgText.replace(/\s+/g, ' '); // one space only
    text = text.trim();
    var date = this.state.currDate;
    var errors = [];
    
    this.state.errors = [];
    if (!text) {
      this.setState({errors: ["Нет текста телеграммы"]});
      return;
    }
    this.observation = {};
    this.observation.telegram = text;
    switch (this.state.tlgType) {
      case 'synoptic':
        if (!checkSynopticTelegram(term, text, errors, this.props.stations, this.observation)){
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
        break;
      case 'agro':
        if (text.substr(0,5) != 'ЩЭАГЯ') {
          this.setState({errors: ["Ошибка в опознавательных буквах"]});
          return;
        }
        if (!checkAgroTelegram(text, this.props.stations, errors, this.observation)) {
          this.setState({errors: errors});
          return;
        }
        break;
      case 'agro_dec':
        if (text.substr(0,5) != 'ЩЭАГУ') {
          this.setState({errors: ["Ошибка в опознавательных буквах"]});
          return;
        }
        if (!checkAgroTelegram(text, this.props.stations, errors, this.observation)) {
          this.setState({errors: errors});
          return;
        }
        break;
      case 'sea':
        this.observation.day_obs = text.substr(5,2);
        this.observation.term = text.substr(7,2);
        break;
    }
    this.props.onFormSubmit({observation: this.observation, currDate: date, tlgType: this.state.tlgType, tlgText: this.state.tlgText});
    this.setState({
      tlgText: '',
      errors: []
    });
  }

  dateChange(e){
    this.setState({currDate: e.target.value});
  }

  handleOptionSelected(value, senderName){
    if (senderName == 'selectTypes'){
      if (this.props.inputMode == 'normal'){
        let t = Math.floor(new Date().getUTCHours() / 3) * 3;
        this.state.tlgTerm = t < 10 ? '0'+t : t;
      }
      this.state.tlgType = value;
      this.props.onTelegramTypeChange(value, this.state.tlgTerm);
      this.setState({tlgType: value, errors: []});
    }else{
      this.setState({tlgTerm: value, errors: []});
    }
  }

  handleTextChange(e) {
    this.setState({tlgText: e.target.value, errors: []});
  }
  
  inBufferClick(e){
    this.props.onInBuffer({tlgText: this.state.tlgText, message: this.state.errors[0], tlgType: this.state.tlgType});
    this.setState({tlgText: '', errors: []});
  }

  render() {
    const types = [
      { value: 'synoptic',  label: 'Синоптические' },
      { value: 'agro',      label: 'Агро ежедневные' },
      { value: 'agro_dec',  label: 'Агро декадные' },
      { value: 'storm',     label: 'Штормовые' },
      // { value: 'sea',       label: 'Морские' },
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

    let tlgDate = this.props.inputMode == 'normal' ? <td>{this.state.currDate}</td> : <td><input type="date" name="input-date" value={this.state.currDate} onChange={this.dateChange} required="true" autoComplete="on" /></td>;
    let term = this.state.tlgType == 'synoptic' ? <td>{this.state.tlgTerm}</td> : <td></td>;
    let termSelect = this.state.tlgType == 'synoptic' ? <td><OptionSelect options={terms} onUserInput={this.handleOptionSelected} name = "selectTerms" defaultValue={this.state.tlgTerm} readOnly="readonly"/></td> : <td></td>;
    let inBuffer = this.state.errors[0] > '' && this.state.tlgText > '' ? <button style={{float: "right"}} type="button" id="in-buffer" onClick={(event) => this.inBufferClick(event)}>В буфер</button> : '';
    return (
    <div className="col-md-12">
      <form className="telegramForm" onSubmit={(event) => this.handleSubmit(event)}>
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
              {tlgDate}
              <td><OptionSelect options={types} onUserInput={this.handleOptionSelected} name = "selectTypes" defaultValue={this.state.tlgType}/></td>
              {this.props.inputMode == 'normal' ? term : termSelect}
            </tr>
          </tbody>
        </table>
        <p>Текст 
          <input type="text" value={this.state.tlgText} onChange={(event) => this.handleTextChange(event)}/>
          <span style={{color: 'red'}}>{this.state.errors[0]}</span>
          {inBuffer}
        </p>
        <input type="submit" value="Сохранить" />
      </form>
    </div>
    );
  }
}

class TextTelegramEditForm extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      tlgText: this.props.tlgText,
    };
  }
  
  handleTextChange(e) {
    this.setState({tlgText: e.target.value});
  }
  
  handleEditSubmit(e){
    e.preventDefault();
    this.props.onTelegramEditSubmit(this.state.tlgText);
  }
  
  render() {
    return (
      <form className="telegramEditForm" onSubmit={(event) => this.handleEditSubmit(event)}>
        <input type="text" value={this.state.tlgText} onChange={(event) => this.handleTextChange(event)}/>
        <span style={{color: 'red'}}>{this.props.errors[0]}</span>
        <input type="submit" value="Сохранить" />
      </form>
    );
  }
}

class TelegramRow extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      tlgText: this.props.telegram.telegram,
      errors: [],
      source: 'outside',
      mode: 'Изменить'
    };
    this.handleEditClick = this.handleEditClick.bind(this);
    this.handleEditTelegramSubmit = this.handleEditTelegramSubmit.bind(this);
  }
  handleEditClick(e){
    if (this.state.mode == 'Изменить') 
      this.setState({mode:'Отменить', errors: []});
    else
      this.setState({mode:'Изменить'});
  }
  handleEditTelegramSubmit(tlgText){
    tlgText = tlgText.replace(/\s+/g, ' ');
    var errors = [];
    var tlgData = {};
    var observation = {};
    var desiredLink = '';
    switch(this.props.tlgType) {
      case 'synoptic':
        if (!checkSynopticTelegram(this.props.telegram.term, tlgText, errors, this.props.stations, observation)){
          this.setState({errors: errors});
          return;
        }
        desiredLink = "/synoptic_observations/update_synoptic_telegram?id="+this.props.telegram.id; //+"&telegram="+tlgText;
        tlgData = {observation: observation};
        break;
      case 'agro':
        if (!checkAgroTelegram(tlgText, this.props.stations, errors, observation)) {
          this.setState({errors: errors});
          return;
        }
        let c_d = observation.damage_crops;
        let c_c = observation.state_crops;
        tlgData = {agro_observation: observation, crop_conditions: c_c, crop_damages: c_d};
        if (observation.state_crops)
          delete observation.state_crops;
        if (observation.damage_crops)
          delete observation.damage_crops;

        desiredLink = "/agro_observations/update_agro_telegram?id="+this.props.telegram.id; //+"&telegram="+tlgText;
        break;
      case 'agro_dec':
        if (!checkAgroTelegram(tlgText, this.props.stations, errors, observation)) {
          this.setState({errors: errors});
          return;
        }
        c_c = observation.state_crops;
        tlgData = {agro_dec_observation: observation, crop_conditions: c_c};
        if (observation.state_crops)
          delete observation.state_crops;

        desiredLink = "/agro_dec_observations/update_agro_dec_telegram?id="+this.props.telegram.id;
        break;
      case 'storm':
        if (!checkStormTelegram(tlgText, this.props.stations, errors, observation)){
          this.setState({errors: errors});
          return;
        }
        tlgData = {storm_observation: observation};
        desiredLink = "/storm_observations/update_storm_telegram?id="+this.props.telegram.id+"&telegram="+tlgText;
        break;
      case 'sea':
        observation.day_obs = tlgText.substr(5,2);
        observation.term = tlgText.substr(7,2);
        tlgData = {sea_observation: observation};
        desiredLink = "/sea_observations/update_sea_telegram?id="+this.props.telegram.id+"&telegram="+tlgText;
    }
    observation.telegram = tlgText;
    this.setState({mode: "Изменить", tlgText: tlgText, source: 'inside'});
    $.ajax({
      type: 'PUT',
      dataType: 'json',
      data: tlgData,
      url: desiredLink
      }).done((data) => {})
      .fail((jqXhr) => {
        console.log('failed to register');
      });
  }
  render() {
    if(this.state.source == 'outside')
      this.state.tlgText = this.props.telegram.telegram;
    var desiredLink = "/"+this.props.tlgType+"_observations/"+this.props.telegram.id;
    var term = this.props.tlgType == 'synoptic' ? <td>{this.props.telegram.term < 10 ? '0'+this.props.telegram.term : this.props.telegram.term}</td> : '';
    
    return (
      <tr key = {this.props.telegram.id}>
        <td>{this.props.telegram.date.substr(0, 19)+' UTC'}</td>
        {term}
        <td>{this.props.telegram.station_name}</td>
        {this.state.mode == 'Изменить' ? <td><a href={desiredLink}>{this.state.tlgText}</a></td> : <td><TextTelegramEditForm tlgText={this.state.tlgText} onTelegramEditSubmit={this.handleEditTelegramSubmit} errors = {this.state.errors}/></td> }
        <td><input id={this.props.telegram.id} type="submit" value={this.state.mode} onClick={(event) => this.handleEditClick(event)}/></td> 
      </tr>
    );
  }
}

const LastTelegramsTable = ({telegrams, tlgType, stations}) => {
  var rows = [];
  telegrams.forEach((t) => {
    t.date = t.date.replace(/T/, " ");
    rows.push(<TelegramRow telegram={t} key={t.id} tlgType={tlgType} stations={stations}/>);
  });
  return (
    <table className="table table-hover">
      <thead>
        <tr>
          <th width = "200px">Дата</th>
          { tlgType == 'synoptic' ? <th>Срок</th> : '' }
          <th>Метеостанция</th>
          <th>Текст</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>{rows}</tbody>
    </table>
  );
};

class InputTelegrams extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      inputMode: this.props.inputMode,
      currDate: this.props.currDate,
      tlgType: this.props.tlgType,
      tlgTerm: this.props.term,
      errors: [],
      telegrams: this.props.telegrams
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
    this.handleTelegramTypeChanged = this.handleTelegramTypeChanged.bind(this);
  }

  handleTelegramTypeChanged(tlgType, tlgTerm){
    var that = this;
    var desiredLink = "/"+tlgType+"_observations/get_last_telegrams";
    this.state.tlgTerm = tlgTerm;
    this.setState({tlgType: tlgType});
    $.ajax({
      type: 'GET',
      dataType: 'json',
      url: desiredLink
      }).done((data) => {
        that.setState({telegrams: data.telegrams, tlgType: data.tlgType, errors: []});
      }).fail((res) => {
        that.setState({errors: ["Проблемы с чтением данных из БД"]});
      }); 
  }
  
  handleFormSubmit(telegram) {
    var that = this;
    var tlgData = {};
    var desiredLink = '';
    switch(telegram.tlgType) {
      case 'synoptic':
        tlgData = {observation: telegram.observation},
        desiredLink = "/synoptic_observations/create_synoptic_telegram?date="+telegram.currDate+"&input_mode="+this.state.inputMode;
        break;
      case 'agro':
        let c_d = telegram.observation.damage_crops;
        let c_c = telegram.observation.state_crops;
        tlgData = {agro_observation: telegram.observation, crop_conditions: c_c, crop_damages: c_d};
        if (telegram.observation.state_crops)
          delete telegram.observation.state_crops;
        if (telegram.observation.damage_crops)
          delete telegram.observation.damage_crops;
        desiredLink = "/agro_observations/create_agro_telegram?date="+telegram.currDate+"&input_mode="+this.state.inputMode;
        break;
      case 'agro_dec':
        c_c = telegram.observation.state_crops;
        tlgData = {agro_dec_observation: telegram.observation, crop_dec_conditions: c_c};
        if (telegram.observation.state_crops)
          delete telegram.observation.state_crops;
        desiredLink = "/agro_dec_observations/create_agro_dec_telegram?date="+telegram.currDate+"&input_mode="+this.state.inputMode;
        break;
      case 'storm':
        tlgData = {storm_observation: telegram.observation};
        desiredLink = "/storm_observations/create_storm_telegram?date="+telegram.currDate+"&input_mode="+this.state.inputMode;
        break;
      case 'sea':
        tlgData = {sea_observation: telegram.observation};
        desiredLink = "/sea_observations/create_sea_telegram?date="+telegram.currDate+"&input_mode="+this.state.inputMode;
    }
    $.ajax({
      type: 'POST',
      dataType: 'json',
      data: tlgData, 
      url: desiredLink
      }).done((data) => {
        that.setState({telegrams: data.telegrams, tlgType: data.tlgType, currDate: data.currDate, inputMode: data.inputMode, errors: data.errors});
        alert(this.state.errors[0]);
      }).fail((res) => {
        that.setState({errors: ["Ошибка записи в базу"]});
      }); 
  }
  
  handleInBuffer(forBuffer){
    var that = this;
    $.ajax({
      type: 'POST',
      dataType: 'json',
      data: forBuffer, 
      url: "/applicants/to_buffer"
      }).done((data) => {
        alert("Данные занесены в буфер");
        that.setState({telegrams: data.telegrams, tlgType: data.tlgType, currDate: data.currDate, inputMode: "normal", errors: []});
      }).fail((res) => {
        that.setState({errors: ["Ошибка записи в буфер"]});
      }); 
  }

  render(){
    let telegramTable = this.props.telegrams.length > 0 ? <div>
      <h3>Телеграммы {this.state.tlgType}</h3> 
      <LastTelegramsTable telegrams={this.state.telegrams} tlgType={this.state.tlgType} stations={this.props.stations}/>
      </div> : '';
    return(
      <div>
        <h3>Новая телеграмма</h3>
        <NewTelegramForm currDate={this.state.currDate} tlgType={this.state.tlgType} onTelegramTypeChange={this.handleTelegramTypeChanged} onFormSubmit={this.handleFormSubmit} stations={this.props.stations} term={this.props.term} inputMode={this.props.inputMode} onInBuffer={this.handleInBuffer}/>
        {telegramTable}
      </div>
    );
  }
}

function checkAgroTelegram(tlg, stations, errors, observation){
  // ЩЭАГЯ - ежедневная, ЩЭАГУ - декадная
  if(~tlg.indexOf("ЩЭАГЯ ") || ~tlg.indexOf("ЩЭАГУ ") ){
    observation.telegram_type = tlg.substr(0, 5);
  } else {
    errors.push("Ошибка в различительной группе");
    return false;
  }
  var codeStation = tlg.substr(6,5);
  var isStation = false; 
  var idStation;
  isStation = stations.some(function(s){
    idStation = s.id;
    return +codeStation == s.code;
  });
  if (isStation) {
    observation.station_id = idStation;
  } else {
    errors.push("Ошибка в коде станции");
    return false;
  }
  
  var value;
  value = +tlg.substr(12, 2);
  if (observation.telegram_type == 'ЩЭАГЯ')
    if (1 <= value && value <= 31)
      observation.day_obs = value;
    else {
      errors.push("Ошибка в дне наблюдения");
      return false;
    }
  else
    if ([10, 20, 28, 29, 30, 31].some(elem => elem == value))
      observation.day_obs = value;
    else {
      errors.push("Ошибка в дне наблюдения");
      return false;
    }
    
  value = +tlg.substr(14, 2);
  if (1 <= value && value <= 12)
    observation.month_obs = value;
  else {
    errors.push("Ошибка в месяце наблюдения");
    return false;
  }
  
  value = +tlg.substr(16, 1);
  if (1 <= value && value <= 8)
    observation.telegram_num = value;
  else {
    errors.push("Ошибка в номере телеграммы");
    return false;
  }
  
  var currentPos;
  var sign = {'0': '', '1': '-'};
  if (observation.telegram_type == 'ЩЭАГЯ'){ // ежедневные
    if (tlg.substr(17,5) != ' 333 '){
      errors.push("Ошибка в признаке раздела 3");
      return false;
    }
    if (/^90[01]\d{2}$/.test(tlg.substr(22,5))){
      observation.temperature_max_12 = sign[tlg[24]]+tlg.substr(25,2);
    } else {
      errors.push("Ошибка в разделе 3 зона 90");
      return false;
    }
    currentPos = 28;
    // if ([1, 3, 4, 5, 6, 7, 8].some(elem => elem == +tlg[currentPos])){
    // }else{
    //   errors.push("Ошибка в признаке группы зоны 90");
    //   return false;
    // }
    if (tlg[currentPos] == '1') 
      if (/^1[01]\d{3}$/.test(tlg.substr(currentPos,5))){
        observation.temperature_avg_24 = sign[tlg[currentPos+1]]+tlg.substr(currentPos+2,2)+'.'+tlg[currentPos+4];
        currentPos += 6;
      }else{
        errors.push("Ошибка в группе 1 зоны 90 раздела 3");
        return false;
      }
    if (tlg[currentPos] == '3') 
      if (/^3[01]\d{2}\/$/.test(tlg.substr(currentPos,5))){
        observation.temperature_min_24 = sign[tlg[currentPos+1]]+tlg.substr(currentPos+2,2);
        currentPos += 6;
      }else{
        errors.push("Ошибка в группе 3 зоны 90 раздела 3");
        return false;
      }
    if (tlg[currentPos] == '4') 
      if (/^4[01]\d{2}\/$/.test(tlg.substr(currentPos,5))){
        observation.temperature_min_soil_24 = sign[tlg[currentPos+1]]+tlg.substr(currentPos+2,2);
        currentPos += 6;
      }else{
        errors.push("Ошибка в группе 4 зоны 90 раздела 3");
        return false;
      }
    if (tlg[currentPos] == '5') 
      if (/^5\d{3}[1-5/]$/.test(tlg.substr(currentPos,5))){
        observation.percipitation_24 = tlg.substr(currentPos+1,3);
        observation.percipitation_type = tlg[currentPos+4] == '/' ? null : tlg[currentPos+4];
        currentPos += 6;
      }else{
        errors.push("Ошибка в группе 5 зоны 90 раздела 3");
        return false;
      }
    if (tlg[currentPos] == '6') 
      if (/^6\d{3}\/$/.test(tlg.substr(currentPos,5))){
        observation.percipitation_12 = tlg.substr(currentPos+1,3);
        currentPos += 6;
      }else{
        errors.push("Ошибка в группе 6 зоны 90 раздела 3");
        return false;
      }
    if (tlg[currentPos] == '7') 
      if (/^7\d{4}$/.test(tlg.substr(currentPos,5))){
        observation.wind_speed_max_24 = tlg.substr(currentPos+1,2);
        observation.saturation_deficit_max_24 = tlg.substr(currentPos+3,2);
        currentPos += 6;
      }else{
        errors.push("Ошибка в группе 7 зоны 90 раздела 3");
        return false;
      }
    if (tlg[currentPos] == '8') 
      if (/^8\d{2}[012/]{2}$/.test(tlg.substr(currentPos,5))){ // 20180530 added '/' согласовал с Б.Л.Н.
        observation.duration_dew_24 = tlg.substr(currentPos+1,2);
        if (tlg[currentPos+3] != '/')
          observation.dew_intensity_max = tlg[currentPos+3];
        if (tlg[currentPos+4] != '/')
          observation.dew_intensity_8 = tlg[currentPos+4];
        currentPos += 6;
      }else{
        errors.push("Ошибка в группе 8 зоны 90 раздела 3");
        return false;
      }
    if (tlg.substr(currentPos, 2) == '91'){
      if (/^91[0-9/]{2}[0-6/]$/.test(tlg.substr(currentPos,5))){
        if (tlg.substr(currentPos+2,2) != '//')
          observation.sunshine_duration_24 = tlg.substr(currentPos+2,2);
        if (tlg[currentPos+4] != '/')
          observation.state_top_layer_soil = tlg[currentPos+4];
        currentPos += 6;
      } else {
        errors.push("Ошибка в разделе 3 зона 91");
        return false;
      }      
      if (tlg[currentPos] == '1') 
        if (/^1\d{4}$/.test(tlg.substr(currentPos,5))){
          observation.temperature_field_5_16 = tlg.substr(currentPos+1,2);
          observation.temperature_field_10_16 = tlg.substr(currentPos+3,2);
          currentPos += 6;
        } else {
          errors.push("Ошибка в группе 1 зоны 91 раздела 3");
          return false;
        }
      if (tlg[currentPos] == '2') 
        if (/^2[0-9/]{4}$/.test(tlg.substr(currentPos,5))){ //20180412 возможны //// В.И.
          if (tlg[currentPos+1] != '/')  
            observation.temperature_avg_soil_5 = tlg.substr(currentPos+1,2);
          if (tlg[currentPos+3] != '/')
            observation.temperature_avg_soil_10 = tlg.substr(currentPos+3,2);
          currentPos += 6;
        } else {
          errors.push("Ошибка в группе 2 зоны 91 раздела 3");
          return false;
        }
      if ((tlg[currentPos] == '3') && (tlg.substr(currentPos,4) != '333 ' ))
        if (/^3\d{4}$/.test(tlg.substr(currentPos,5))){
          observation.saturation_deficit_avg_24 = tlg.substr(currentPos+1,2);
          observation.relative_humidity_min_24 = tlg.substr(currentPos+3,2);
          currentPos += 6;
        } else {
          errors.push("Ошибка в группе 3 зоны 91 раздела 3");
          return false;
        }
      if ((tlg.substr(currentPos,2) == '92') || (tlg.substr(currentPos,4) == '333 ') || (tlg[currentPos-1] == '=')){ // mwm 20180618
      } else { 
        errors.push("Ошибка в зоне 91 раздела 3 =>"+tlg.substr(currentPos));
        return false;
      }
    }

    let zone92pos = tlg.search(/92... [1678]/);
    let zone92_95pos = tlg.search(/92... 95/);
    let wrong333pos = tlg.indexOf('333', currentPos);
    let end92pos;
    if (zone92pos > 0){
      if (zone92_95pos > 0)
        end92pos = zone92_95pos;
      else if (wrong333pos > 0)
        end92pos = wrong333pos;
      else
        end92pos = tlg.length;
      currentPos = end92pos;
      let zone = tlg.substr(zone92pos,end92pos-zone92pos).split('92');
      zone.splice(0,1);
      var state_crops;
      observation.state_crops = [];
      let code = true;
      zone.forEach((t, i) => {
        state_crops = {};
        state_crops.crop_code = t.substr(0, 3);
        let pos = 4;
        let j = 1;
        while (t.indexOf(' 1', pos-1)>0){
          if((j<6) && (/^1\d{2}[0-5/]\/$/.test(t.substr(pos,5)))){ // 20180405 В.И. на позиции 4 допустима /
            state_crops["development_phase_"+j] = t.substr(pos+1,2);
            state_crops["assessment_condition_"+j] = t[pos+3];
            j += 1;
            pos += 6;
          }else {
            errors.push("Ошибка в группе 1["+j+"] зоны 92["+(i+1)+"] раздела 3");
            return code = false;
          }
        }
        
        j = 1;
        while (t.indexOf(' 6', pos-1)>0){
          if((j<6) && (/^6\d{3}[123]$/.test(t.substr(pos,5)))){
            state_crops["agricultural_work_"+j] = t.substr(pos+1,3);
            state_crops["index_weather_"+j] = t[pos+4];
            j += 1;
            pos += 6;
          }else {
            errors.push("Ошибка в группе 6["+j+"] зоны 92["+(i+1)+"] раздела 3"+t.substr(pos,5));
            return code = false;
          }
        }
        
        j = 1;
        while (t.indexOf(' 7', pos-1)>0){
          if((j<6) && (/^7\d{3}[1-5]$/.test(t.substr(pos,5)))){
            state_crops["damage_plants_"+j] = t.substr(pos+1,3);
            state_crops["damage_volume_"+j] = t[pos+4];
            j += 1;
            pos += 6;
          }else {
            errors.push("Ошибка в группе 7["+j+"] зоны 92["+(i+1)+"] раздела 3");
            return code = false;
          }
        }
        
        if (pos < t.length){
          errors.push("Ошибка в зоне 92["+(i+1)+"] раздела 3 =>"+t.substr(pos));
          code = false;
        } else
          observation.state_crops.push(state_crops);
      });
      if (!code)
        return false;
    }
    
    if (zone92_95pos > 0){
      if (wrong333pos > 0)
        end92pos = wrong333pos;
      else
        end92pos = tlg.length;
      currentPos = end92pos;
      let zone = tlg.substr(zone92_95pos,end92pos-zone92_95pos).split('92');
      zone.splice(0,1);
      observation.damage_crops = [];
      let damage_crops;
      let code = true;
      zone.forEach((t, i) => {
        damage_crops = {};
        damage_crops.crop_code = t.substr(0, 3);
        let pos = 4;
        if( (/^95[0-9/]{3}$/.test(t.substr(pos,5)))){ // добавил /// по согласованию с В.И. 2018.02.28 (см. стр. 35)
          if (t[pos+2] != '/')
            damage_crops.height_snow_cover_rail = t.substr(pos+2,3);
          pos += 6;
        }else {
          errors.push("Ошибка в группе 95 зоны 92_95["+(i+1)+"] раздела 3");
          return code = false;
        }
        
        if (t[pos] == '4')
          if( (/^4\d{3}\/$/.test(t.substr(pos,5)))){
            damage_crops.depth_soil_freezing = t.substr(pos+1,3);
            pos += 6;
          }else {
            errors.push("Ошибка в группе 4 зоны 92_95["+(i+1)+"] раздела 3");
            return code = false;
          }
        
        if (t[pos] == '5')
          if( (/^5[1-7][01]\d{2}$/.test(t.substr(pos,5)))){
            damage_crops.thermometer_index = t[pos+1];
            damage_crops.temperature_dec_min_soil3 = sign[t[pos+2]]+t.substr(pos+3,2);
            pos += 6;
          }else {
            errors.push("Ошибка в группе 5 зоны 92_95["+(i+1)+"] раздела 3");
            return code = false;
          }
          
        if (pos < t.length){
          errors.push("Ошибка в зоне 92_95["+(i+1)+"] раздела 3 =>"+t.substr(pos));
          code = false;
        } else
          observation.damage_crops.push(damage_crops);
      });
      if (!code)
        return false;
    }
    
    if ((tlg[currentPos-1] == '=') || (tlg.substr(currentPos, 3) == '333'))
      return true;
    else {
      errors.push("Ошибка в окончании телеграммы =>"+tlg.substr(currentPos));
      return false;
    }
    
  } else {
    // ЩЭАГУ - декадная
    currentPos = 18;
    if (tlg.substr(17,5) == ' 111 '){
      // if (tlg.substr(17,5) != ' 111 '){
      //   errors.push("Ошибка в признаке раздела 1");
      //   return false;
      // }
      if (/^90[01]\d{2}$/.test(tlg.substr(22,5))){
        observation.temperature_dec_avg_delta = sign[tlg[24]]+tlg.substr(25,2);
      } else {
        errors.push("Ошибка в разделе 1 зона 90");
        return false;
      }
      currentPos = 28;
      if (tlg[currentPos] == '1') 
        if (/^1[01]\d{3}$/.test(tlg.substr(currentPos,5))){
          observation.temperature_dec_avg = sign[tlg[currentPos+1]]+tlg.substr(currentPos+2,2)+'.'+tlg[currentPos+4];
          currentPos += 6;
        }else{
          errors.push("Ошибка в группе 1 зоны 90 раздела 1");
          return false;
        }
      if (tlg[currentPos] == '2') 
        if (/^2[01]\d{2}[0-9/]$/.test(tlg.substr(currentPos,5))){
          observation.temperature_dec_max = sign[tlg[currentPos+1]]+tlg.substr(currentPos+2,2);
          if (tlg[currentPos != '/'])
            observation.hot_dec_day_num = tlg[currentPos+4];
          currentPos += 6;
        }else{
          errors.push("Ошибка в группе 2 зоны 90 раздела 1");
          return false;
        }
      if (tlg[currentPos] == '3') 
        if (/^3[01]\d{2}[0-9/]$/.test(tlg.substr(currentPos,5))){
          observation.temperature_dec_min = sign[tlg[currentPos+1]]+tlg.substr(currentPos+2,2);
          if (tlg[currentPos+4] != '/')
            observation.dry_dec_day_num = tlg[currentPos+4];
          currentPos += 6;
        }else{
          errors.push("Ошибка в группе 3 зоны 90 раздела 1");
          return false;
        }
      if (tlg[currentPos] == '4')
        if (/^4[01]\d{2}[0-9/]$/.test(tlg.substr(currentPos,5))){
          observation.temperature_dec_min_soil = sign[tlg[currentPos+1]]+tlg.substr(currentPos+2,2);
          if (tlg[currentPos+4] != '/')
            observation.cold_soil_dec_day_num = tlg[currentPos+4];
          currentPos += 6;
        }else{
          errors.push("Ошибка в группе 4 зоны 90 раздела 1");
          return false;
        }
      if (tlg[currentPos] == '5')
        if (/^5\d{3}[0-9/]$/.test(tlg.substr(currentPos,5))){
          observation.precipitation_dec = tlg.substr(currentPos+1,3);
          if (tlg[currentPos+4] != '/')
            observation.wet_dec_day_num = tlg[currentPos+4];
          currentPos += 6;
        }else{
          errors.push("Ошибка в группе 5 зоны 90 раздела 1");
          return false;
        }
      if (tlg[currentPos] == '6')
        if (/^6\d{4}$/.test(tlg.substr(currentPos,5))){
          observation.precipitation_dec_percent = tlg.substr(currentPos+1,4);
          currentPos += 6;
        }else{
          errors.push("Ошибка в группе 6 зоны 90 раздела 1");
          return false;
        }
      if (tlg[currentPos] == '7')
        if (/^7\d{2}[0-9/]{2}$/.test(tlg.substr(currentPos,5))){
          observation.wind_speed_dec_max = tlg.substr(currentPos+1,2);
          if (tlg[currentPos+3] != '/')
            observation.wind_speed_dec_max_day_num = tlg[currentPos+3];
          if (tlg[currentPos+4] != '/')
            observation.duster_dec_day_num = tlg[currentPos+4];
          currentPos += 6;
        }else{
          errors.push("Ошибка в группе 7 зоны 90 раздела 1");
          return false;
        }
      if (/^91[01]\d{2}$/.test(tlg.substr(currentPos,5))){
        observation.temperature_dec_max_soil = sign[tlg[currentPos+2]]+tlg.substr(currentPos+3,2);
        currentPos += 6;
      } else {
        errors.push("Ошибка в разделе 1 зона 91 g=>"+tlg.substr(currentPos,5));
        return false;
      }
      if (tlg[currentPos] == '1')
        if (/^1[0-9/]{4}$/.test(tlg.substr(currentPos,5))){ // 20180411 время солнечного сияния м.б. /// А.И.
          if (tlg[currentPos+1] != '/')
            observation.sunshine_duration_dec = tlg.substr(currentPos+1,3);
          if (tlg[currentPos+4] != '/')
            observation.freezing_dec_day_num = tlg[currentPos+4];
          currentPos += 6;
        }else{
          errors.push("Ошибка в группе 1 зоны 91 раздела 1");
          return false;
        }
      if (tlg[currentPos] == '2')
        if (/^2\d{2}[0-9/]{2}$/.test(tlg.substr(currentPos,5))){
          observation.temperature_dec_avg_soil10 = tlg.substr(currentPos+1,2);
          if (tlg[currentPos+3] != '/')
            observation.temperature25_soil10_dec_day_num = tlg[currentPos+3];
          if (tlg[currentPos+4] != '/')
            observation.dew_dec_day_num = tlg[currentPos+4];
          currentPos += 6;
        }else{
          errors.push("Ошибка в группе 2 зоны 91 раздела 1");
          return false;
        }
      if (tlg[currentPos] == '3')
        if (/^3\d{4}$/.test(tlg.substr(currentPos,5))){
          observation.saturation_deficit_dec_avg = tlg.substr(currentPos+1,2);
          observation.relative_humidity_dec_avg = tlg.substr(currentPos+3,2);
          currentPos += 6;
        }else{
          errors.push("Ошибка в группе 3 зоны 91 раздела 1");
          return false;
        }
      if (tlg[currentPos] == '4')
        if (/^4\d{3}[0-9/]$/.test(tlg.substr(currentPos,5))){
          observation.percipitation_dec_max = tlg.substr(currentPos+1,3);
          if (tlg[currentPos+4] != '/')
            observation.percipitation5_dec_day_num = tlg[currentPos+4];
          currentPos += 6;
        }else{
          errors.push("Ошибка в группе 4 зоны 91 раздела 1");
          return false;
        }
    } // контроль раздела 1 закончен
    
    if ((tlg[currentPos-1] == '='))
      return true;
    else 
      if (tlg.substr(currentPos-1,5) != ' 222 '){
        errors.push("Ошибка в признаке раздела 2");
        return false;
      } else
        currentPos += 4;
      
    if (/^92\d{3}$/.test(tlg.substr(currentPos,5))){
      let zone = tlg.substr(currentPos-1).split(' 92');
      zone.splice(0,1);
      // let state_crops;
      observation.state_crops = [];
      let code = true;
      zone.forEach((t, i) => {
        state_crops = {};
        state_crops.crop_code = t.substr(0, 3);
        let pos = 4;
        if (t[4] == '1')
          if (/^1\d{3}[1-7]$/.test(t.substr(pos,5))){
            state_crops.plot_code = t.substr(pos+1,3);
            state_crops.agrotechnology = t[pos+4];
            pos += 6;
          }else{
            errors.push("Ошибка в группе 1 зоны 92["+(i+1)+"] раздела 2");
            return code = false;
          }
        let zonePos = t.search(/ 9/);
        zonePos = zonePos > 0 ? zonePos : t.length-1;
        if(pos < zonePos){ // zone92
          // let zone92 = t.substr(pos, zonePos-pos);
          let j = 1;
          while ((0<t.indexOf(' 2', pos-1)) &&(t.indexOf(' 2', pos-1)<zonePos)){
            if((j<6) && (/^2\d{2}[0-9/][0-5/]$/.test(t.substr(pos,5)))){ // 2018.03.01 mwm assessment_condition => /
              state_crops["development_phase_"+j] = t.substr(pos+1,2);
              if(t[pos+3] != '/')
                state_crops["day_phase_"+j] = t[pos+3];
              if(t[pos+4] != '/')
                state_crops["assessment_condition_"+j] = t[pos+4];
              j += 1;
              pos += 6;
            }else {
              errors.push("Ошибка в группе 2["+j+"] зоны 92["+(i+1)+"] раздела 2");
              return code = false;
            }
          }
          if (t[pos] == '3')
            if (/^3[0-4/][0-9/]{3}$/.test(t.substr(pos,5))){ // 20180503 mwm add ////
              if (t[pos+1] != '/')
                state_crops.clogging_weeds = t[pos+1];
              if (t[pos+2] != '/')
                state_crops.height_plants = t.substr(pos+2,3);
              pos += 6;
            }else{
              errors.push("Ошибка в группе 3 зоны 92["+(i+1)+"] раздела 2");
              return code = false;
            }
          if (t[pos] == '4')
            if (/^4\d{4}$/.test(t.substr(pos,5))){
              state_crops.number_plants = t.substr(pos+2,3);
              pos += 6;
            }else{
              errors.push("Ошибка в группе 4 зоны 92["+(i+1)+"] раздела 2");
              return code = false;
            }
          if (t[pos] == '5')
            if (/^5\d{4}$/.test(t.substr(pos,5))){
              state_crops.average_mass = t.substr(pos+2,3);
              pos += 6;
            }else{
              errors.push("Ошибка в группе 5 зоны 92["+(i+1)+"] раздела 2");
              return code = false;
            }
          j = 1;
          while ((t.indexOf(' 6', pos-1)>0) && (t.indexOf(' 6', pos-1)<zonePos)){
            if((j<6) && (/^6\d{4}$/.test(t.substr(pos,5)))){
              state_crops["agricultural_work_"+j] = t.substr(pos+1,3);
              state_crops["day_work_"+j] = t[pos+4];
              j += 1;
              pos += 6;
            }else {
              errors.push("Ошибка в группе 6["+j+"] зоны 92["+(i+1)+"] раздела 2 g=>"+t.substr(pos,5)+" t=>"+t+" pos=>"+pos);
              return code = false;
            }
          }
          j = 1;
          while ((t.indexOf(' 7', pos-1)>0) && (t.indexOf(' 7', pos-1)<zonePos)){
            if((j<6) && (/^7\d{3}[0-9/]$/.test(t.substr(pos,5)))){  // 20180303 mwm add /
              state_crops["damage_plants_"+j] = t.substr(pos+1,3);
              state_crops["day_damage_"+j] = t[pos+4];
              pos += 6;
            }else {
              errors.push("Ошибка в группе 7["+j+"] зоны 92["+(i+1)+"] раздела 2");
              return code = false;
            }
            if (t[pos] == '0')
              if(/^0[0-9/]{4}$/.test(t.substr(pos,5))){ // mwm 20180521
                if (t[pos+1] != '/')
                  state_crops["damage_level_"+j] = t[pos+1];
                if (t[pos+2] != '/')
                  state_crops["damage_volume_"+j] = t[pos+2];
                if (t[pos+3] != '/')
                  state_crops["damage_space_"+j] = t.substr(pos+3,2);
                pos += 6;
              }else {
                errors.push("Ошибка в группе 0["+j+"] зоны 92["+(i+1)+"] раздела 2");
                return code = false;
              }
            j += 1;
          }
        }
        if (/ 93/.test(t.substr(pos-1,3))){ // zone 93
          if (/^93[0-9/]{3}$/.test(t.substr(pos,5))){
            if (t[pos+2] != '/')
              state_crops.number_spicas = t.substr(pos+2,2);
            if (t[pos+4] != '/')
              state_crops.num_bad_spicas = t[pos+4];
            pos += 6;
          }else {
            errors.push("Ошибка в группе 93 зоны 92["+(i+1)+"] раздела 2");
            return code = false;
          }
          if (t[pos] == '1')
            if (/^1\d{4}$/.test(t.substr(pos,5))){
              state_crops.number_stalks = t.substr(pos+1,4);
              pos += 6;
            }else {
              errors.push("Ошибка в группе 1 зоны 92["+(i+1)+"]-93 раздела 2");
              return code = false;
            }
          if (t[pos] == '2')
            if (/^2\d{4}$/.test(t.substr(pos,5))){
              state_crops.stalk_with_spike_num = t.substr(pos+1,4);
              pos += 6;
            }else {
              errors.push("Ошибка в группе 2 зоны 92["+(i+1)+"]-93 раздела 2");
              return code = false;
            }
          if (t[pos] == '3')
            if (/^3[0-9/]{4}$/.test(t.substr(pos,5))){ // 20180621 mwm add /
              if(t[pos+1] != '/')
                state_crops.normal_size_potato = t.substr(pos+1,2);
              if(t[pos+3] != '/')
                state_crops.losses = t.substr(pos+3,2);
              pos += 6;
            }else {
              errors.push("Ошибка в группе 3 зоны 92["+(i+1)+"]-93 раздела 2");
              return code = false;
            }
          if (t[pos] == '4')
            if (/^4[0-9/]{4}$/.test(t.substr(pos,5))){  // 20180621 mwm add /
              if(t[pos+1] != '/')
                state_crops.grain_num = t.substr(pos+1,3);
              if(t[pos+4] != '/')
                state_crops.bad_grain_percent = t[pos+4];
              pos += 6;
            }else {
              errors.push("Ошибка в группе 4 зоны 92["+(i+1)+"]-93 раздела 2");
              return code = false;
            }
          if (t[pos] == '5')
            if (/^5[0-9/]{4}$/.test(t.substr(pos,5))){ // 20180504 mwm add ////
              if(t[pos+1] != '/')
                state_crops.bushiness = t.substr(pos+1,2);
              if(t[pos+3] != '/')
                state_crops.shoots_inflorescences = t.substr(pos+3,2);
              pos += 6;
            }else {
              errors.push("Ошибка в группе 5 зоны 92["+(i+1)+"]-93 раздела 2");
              return code = false;
            }
          if (t[pos] == '6')
            if (/^6\d{4}$/.test(t.substr(pos,5))){
              state_crops.grain1000_mass = t.substr(pos+1,3)+'.'+t[pos+4];
              pos += 6;
            }else {
              errors.push("Ошибка в группе 6 зоны 92["+(i+1)+"]-93 раздела 2");
              return code = false;
            }
        }
        if (/ 94/.test(t.substr(pos-1,3))){ // zone 94
          if (/^94\d{3}$/.test(t.substr(pos,5))){
            state_crops.moisture_reserve_10 = t.substr(pos+2,3);
            pos += 6;
          }else {
            errors.push("Ошибка в группе 94 зоны 92["+(i+1)+"] раздела 2");
            return code = false;
          }
          if (t[pos] == '1')
            if (/^1\d{4}$/.test(t.substr(pos,5))){
              state_crops.moisture_reserve_5 = t.substr(pos+1,3);
              state_crops.soil_index = t[pos+4];
              pos += 6;
            }else {
              errors.push("Ошибка в группе 1 зоны 92["+(i+1)+"]-94 раздела 2");
              return code = false;
            }
          if (t[pos] == '2')
            if (/^2\d{4}$/.test(t.substr(pos,5))){
              state_crops.moisture_reserve_2 = t.substr(pos+1,2);
              state_crops.moisture_reserve_1 = t.substr(pos+3,2);
              pos += 6;
            }else {
              errors.push("Ошибка в группе 2 зоны 92["+(i+1)+"]-94 раздела 2");
              return code = false;
            }
          if (t[pos] == '4')
            if (/^4\d{4}$/.test(t.substr(pos,5)) && (state_crops.crop_code == '008')){
              state_crops.temperature_water_2 = t.substr(pos+1,2);
              state_crops.depth_water = t.substr(pos+3,2);
              pos += 6;
            }else {
              errors.push("Ошибка в группе 4 зоны 92["+(i+1)+"]-94 раздела 2");
              return code = false;
            }
          if (t[pos] == '5')
            if (/^5\d{4}$/.test(t.substr(pos,5))){
              state_crops.depth_groundwater = t.substr(pos+1,4);
              pos += 6;
            }else {
              errors.push("Ошибка в группе 5 зоны 92["+(i+1)+"]-94 раздела 2");
              return code = false;
            }
          if (t[pos] == '6')
            if (/^6\d{3}\/$/.test(t.substr(pos,5))){
              state_crops.depth_thawing_soil = t.substr(pos+1,3);
              pos += 6;
            }else {
              errors.push("Ошибка в группе 6 зоны 92["+(i+1)+"]-94 раздела 2");
              return code = false;
            }
          if (t[pos] == '7')
            if (/^7\d{3}\/$/.test(t.substr(pos,5))){
              state_crops.depth_soil_wetting = t.substr(pos+1,3);
              pos += 6;
            }else {
              errors.push("Ошибка в группе 7 зоны 92["+(i+1)+"]-94 раздела 2");
              return code = false;
            }
        }
        if (/ 95/.test(t.substr(pos-1,3))){ // zone 95
          if (/^95[0-9/]{3}$/.test(t.substr(pos,5))){
            state_crops.height_snow_cover = t.substr(pos+2,3);
            pos += 6;
          }else {
            errors.push("Ошибка в группе 95 зоны 92["+(i+1)+"] раздела 2");
            return code = false;
          }
        if (t[pos] == '1')
          if (/^1[1-4]\d[0-9/]{2}$/.test(t.substr(pos,5))){
            state_crops.snow_retention = t[pos+1];
            state_crops.snow_cover = t[pos+2];
            if(t[pos+3] != '/')
              state_crops.snow_cover_density = '0.'+t.substr(pos+3,2);
            pos += 6;
          }else {
            errors.push("Ошибка в группе 1 зоны 92["+(i+1)+"]-95 раздела 2");
            return code = false;
          }
        if (t[pos] == '2')
          if (/^2\d{3}[0-9/]$/.test(t.substr(pos,5))){
            state_crops.number_measurements_0 = t[pos+1];
            state_crops.number_measurements_3 = t[pos+2];
            state_crops.number_measurements_30 = t[pos+3];
            if (t[pos+4] != '/')
              state_crops.ice_crust = t[pos+4];
            pos += 6;
          }else {
            errors.push("Ошибка в группе 2 зоны 92["+(i+1)+"]-95 раздела 2");
            return code = false;
          }
        if (t[pos] == '3')
          if (/^3[0-9/]{2}\d{2}$/.test(t.substr(pos,5))){
            if (t[pos+1] != '/')
              state_crops.thickness_ice_cake = t.substr(pos+1,2);
            state_crops.depth_thawing_soil_2 = t.substr(pos+3,2);
            pos += 6;
          }else {
            errors.push("Ошибка в группе 3 зоны 92["+(i+1)+"]-95 раздела 2");
            return code = false;
          }
        if (t[pos] == '4')
          if (/^4\d{3}[0-9/]$/.test(t.substr(pos,5))){
            state_crops.depth_soil_freezing = t.substr(pos+1,3);
            if (t[pos+4] != '/')
              state_crops.thaw_days = t[pos+4];
            pos += 6;
          }else {
            errors.push("Ошибка в группе 4 зоны 92["+(i+1)+"]-95 раздела 2");
            return code = false;
          }
        if (t[pos] == '5')
          if (/^5[1-7][01]\d\d$/.test(t.substr(pos,5))){
            state_crops.thermometer_index = t[pos+1];
            state_crops.temperature_dec_min_soil3 = sign[t[pos+2]]+t.substr(pos+3,2);
            pos += 6;
          }else {
            errors.push("Ошибка в группе 5 зоны 92["+(i+1)+"]-95 раздела 2");
            return code = false;
          }
        if (t[pos] == '6')
          if (/^6\d{3}\/$/.test(t.substr(pos,5))){
            state_crops.height_snow_cover_rail = t.substr(pos+1,3);
            pos += 6;
          }else {
            errors.push("Ошибка в группе 6 зоны 92["+(i+1)+"]-95 раздела 2");
            return code = false;
          }
        if (t[pos] == '7')
          if (/^7[12389][0-9/]\d{2}$/.test(t.substr(pos,5))){ // 20180303 mwm add /
            state_crops.viable_method = t[pos+1];
            state_crops.soil_index_2 = t[pos+2];
            state_crops.losses_1 = t.substr(pos+3,2);
            pos += 6;
          }else {
            errors.push("Ошибка в группе 7 зоны 92["+(i+1)+"]-95 раздела 2");
            return code = false;
          }
        if (t[pos] == '8')
          if (/^8[0-9/]{2}\d{2}$/.test(t.substr(pos,5))){  // 20180303 mwm add //
            state_crops.losses_2 = t.substr(pos+1,2);
            state_crops.losses_3 = t.substr(pos+3,2);
            pos += 6;
          }else {
            errors.push("Ошибка в группе 8 зоны 92["+(i+1)+"]-95 раздела 2");
            return code = false;
          }
        if (t[pos] == '0')
          if (/^0\d\d[0-9/]{2}$/.test(t.substr(pos,5))){
            state_crops.losses_4 = t.substr(pos+1,2);
            if (t[pos+3] != '/')
              state_crops.temperature_dead50 = t.substr(pos+3,2);
            pos += 6;
          }else {
            errors.push("Ошибка в группе 0 зоны 92["+(i+1)+"]-95 раздела 2");
            return code = false;
          }
        }
        if (pos < t.length){
          errors.push("Ошибка в зоне 92["+(i+1)+"] раздела 2 pos=>"+pos+"; length=>"+t.length+" t=>"+t.substr(pos));
          code = false;
        } else{
          currentPos += t.length+(i<zone.length-1 ? 3:2);
          observation.state_crops.push(state_crops);
        }
      });
      if (!code)
        return false;
      
    }else{
      errors.push("Отсутствует обязательная зона 92 раздела 2");
      return false;
    }
    if ((tlg[currentPos-1] == '='))
      return true;
    else {
      errors.push("Ошибка в окончании телеграммы =>"+tlg.substr(currentPos));
      return false;
    }
  }
  
  // function check3section(section3, i){
  //   return true;
  // }
}
function checkStormTelegram(tlg, stations, errors, observation){
  // tlg = tlg.replace(/\s+/g, ' ');
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
  value = +tlg.substr(18,2);
  if ((value > 0) && (value < 32)){
    observation.day_event = value;
  } else {
    errors.push("Ошибка в номере дня");
    return false;
  }
  value = +tlg.substr(20,2);
  if ((value >= 0) && (value < 24)){
    observation.hour_event = value;
  } else {
    errors.push("Ошибка в часе явления");
    return false;
  }
  value = +tlg.substr(22,2);
  if ((value >= 0) && (value < 60)){
    observation.minute_event = value;
  } else {
    errors.push("Ошибка в минутах явления");
    return false;
  }
  if(tlg[24] != '1') {
    errors.push("Ошибка вида телеграммы (a=1)");
    return false;
  }
  
  var windDirections = Array.from({ length: 37 }, (v, k) => k);
  windDirections.push(99);
  var codeWAREP = +tlg.substr(26,2);
  var currentPos = 29;
  
  while (currentPos <= tlg.length){
    if (isCodeWAREP()) {
      if (tlg[currentPos-1] == '=' && observation.telegram_type == 'ЩЭОЗМ') return true;
    } else {
      errors.push("Ошибочный код WAREP");
      return false;
    }
    if (checkByCode())
      if (tlg[currentPos-1] == '=')
        return true;
      else {
        codeWAREP = +tlg.substr(currentPos, 2);
        currentPos += 3;
      }
    else{
      return false;
    }
  }
  errors.push("Ошибка в окончании телеграммы");
  return false;
  
  function isCodeWAREP(){ 
    return [11, 12, 17, 18, 19, 30, 36, 40, 41, 50, 51, 52, 53, 54, 55, 56, 57, 61, 62, 64, 65, 66, 68, 71, 75, 78, 90, 91, 92, 95].some(s => {
      return codeWAREP == s;
    });
  }
  function isGroup1(code, pos) {
    var value = +tlg.substr(pos+1,2);
    var avg_wind = ((code == 17) || (code == 18)) ? (tlg.substr(pos+3,2) == '//') : (0 < +tlg.substr(pos+3,2) <= 99);
    return (/^1[0-39]\d[0-9/]{4}$/.test(tlg.substr(pos, 7)) && windDirections.some(elem => elem == value) && avg_wind && (0 < +tlg.substr(pos+5,2) <= 99));
  }
  function isGroup2(pos){
    let correctDirection;
    let val = tlg.substr(pos+1,2);
    correctDirection = ((val == '//') || windDirections.some(elem => elem == +val));
    val = +tlg.substr(pos+3,2);
    let correctPrecipitation = (val == 17) || (val == 19) || (80 <= val <= 90);
    return (/^2[0-39/][0-9/][189]\d$/.test(tlg.substr(pos,5)) && correctDirection && correctPrecipitation);
  }
  function isGroup7(pos) {
    return (/^7\d{4}[0-9/]{2}$/.test(tlg.substr(pos,7)));
  }
  function isGroup8(pos){
    return /^8[0-9/]{4}$/.test(tlg.substr(pos,5));
  }
  function isGroup3(pos){
    return /^3\d{5}$/.test(tlg.substr(pos,6));
  }
  function isIce(pos){
    return /^[0-9/]{2}[01]\d{2}[12]$/.test(tlg.substr(pos,6));
  }
  function checkByCode(){
    // var group;
    switch (codeWAREP) {
      case 11:
      case 12:
      case 17:
      case 18:
      case 19:
      case 36:
      case 78:
        if (isGroup1(codeWAREP, currentPos)){
          currentPos = currentPos+8;
        } else {
          errors.push("Ошибка в группе 1");
          return false;
        }
        if(codeWAREP == 19)
          if (isGroup2(currentPos)){
            currentPos = currentPos+6;
            return true;
          } else {
            errors.push("Ошибка в группе 2");
            return false;
          }
        else if(codeWAREP == 36 || codeWAREP == 78)
          if (isGroup7(codeWAREP, currentPos)){
            currentPos = currentPos+8;
            return true;
          } else {
            errors.push("Ошибка в группе 7");
            return false;
          }
        else 
          return true;
        // break;
      case 30:
        if (isGroup8(currentPos)){
          currentPos = currentPos+6;
          return true;
        } else {
          errors.push("Ошибка в группе 8");
          return false;
        }
        // break;
      case 40:
      case 41:
        if (isGroup7(currentPos)){
          currentPos += 8;
          if (tlg[currentPos] == '8')
            if (isGroup8(currentPos)){
              currentPos += 6;
              return true;
            } else {
              errors.push("Ошибка в группе 8");
              return false;
            }
          else if (tlg[currentPos] == '1')
            if (isGroup1(codeWAREP, currentPos)){
              currentPos += 8;
              return true;
            } else {
              errors.push("Ошибка в группе 1");
              return false;
            }
          return true;
        }else {
          errors.push("Ошибка в группе 7");
          return false;
        }
      case 50:
      case 51:
      case 52:
      case 53:
      case 54:
      case 55:
      case 56:
      case 57:
        if (isIce(currentPos)){
              currentPos += 7;
              return true;
            } else {
              errors.push("Ошибка в группе 'Гололед'");
              return false;
            }
      case 61:
      case 62:
      case 64:
      case 65:
      case 66:
      case 71:
      case 75:
        if(isGroup3(currentPos)){
          currentPos += 7;
          return true;
        } else {
          errors.push("Ошибка в группе 3");
          return false;
        }
      case 68:
        if (/^[01]\d{2}$/.test(tlg.substr(currentPos,3))){
          currentPos += 4;
          return true;
        } else {
          errors.push("Ошибка в группе 'Ледяной дождь'");
          return false;
        }
      case 90:
      case 92:
        if(/^932\d{2}$/.test(tlg.substr(currentPos,5))){
          currentPos += 6;
          return true;
        } else {
          errors.push("Ошибка в группе 932");
          return false;
        }
      case 91:
        if(isGroup2(currentPos)){
          currentPos += 6;
          return true;
        } else {
          errors.push("Ошибка в группе 2");
          return false;
        }
      case 95:
        if(/^950\d{2}$/.test(tlg.substr(currentPos,5))){
          currentPos += 6;
          return true;
        } else {
          errors.push("Ошибка в группе 950");
          return false;
        }
    }
  }
  // return false; // debug only! 
  // return true;
}
function checkSynopticTelegram(term, tlg, errors, stations, observation){
  // tlg = tlg.replace(/\s+/g, ' ');
  var sign = {'0': '', '1': '-'};
  var state = {
      group00: { errorMessage: 'Ошибка в группе00', regex: /^[134/][12][0-9/]([0-4][0-9]|50|5[6-9]|[6-9][0-9]|\/\/)$/ },  // наблюдатели, Л.А. 20180405 iX = 1 or 2
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
      errors.push("Ошибка в различительной группе =>"+tlg.substr(0, 6)+"; term="+term+';');
      return false;
    }
    var group = tlg.substr(6,5);
    var isStation = false; 
    var idStation = -1;
    isStation = stations.some(function(s){
      idStation = s.id;
      return +group == s.code;
    });
    if (isStation && (tlg[11] == ' ' || tlg[11] == '=')) {
      observation.station_id = idStation;
    } else {
      errors.push("Ошибка в коде метеостанции");
      return false;
    }
    
    group = tlg.substr(12,5);
    var regex = '';
    regex = state.group00.regex;
    if (regex.test(group) && ((tlg[17] == ' ') || (tlg[17] == '='))) {
      if((term==3) || (term==9) || (term==15) || (term==21))  // наблюдатели Донецк 20180405
        if (+tlg[12]!=4){
          errors.push("Для срока "+term+" в группа 00 должно быть iR=4");
          return false;
        }
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
      if ((+tlg[18]>=0) && (+tlg[18]<9))                                    // 20180405 по данным от Л.А.
        if ((+tlg.substr(15,2)>93) && (+tlg.substr(15,2)<=99)){             // 20180615 по данным от Л.А. 99 - теперь правильное значение
        }else{
          errors.push("Дальность видимости не соответствует количеству облаков");
          return false;
        }
      if ((tlg[18]=='/') || (+tlg[18]==9))                                    // 20180405 по данным от Л.А.
        if ((+tlg.substr(15,2)>89) && (+tlg.substr(15,2)<94)){ 
        }else{
          errors.push("Дальность видимости не соответствует количеству облаков");
          return false;
        }
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
      section = tlg.substr(pos555+5, tlg.length-pos555-5-1).trim();
      if(section.length<5){
        errors.push("Ошибка в разделе 5");
        return false;
      }
      // console.log('section5-1:', section);
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
                  // sign = section[2] == '0' ? '' : '-';
                  if (section[0] == '1') 
                    observation.temperature_soil = sign[section[2]]+section.substr(3,2);
                  else 
                    observation.temperature_soil_min = sign[section[2]]+section[3]+'.'+section[4];
                }
                break;
              case '5':
                // sign = section[2] == '0' ? '' : '-';
                observation.temperature_2cm_min = sign[section[2]]+section.substr(3,2);
                break;
              case '6':
                observation.precipitation_2 = section.substr(1,3);
                if ((term == 0) || (term == 12)){
                  if (section[4] != '1'){
                    errors.push("Для срока "+term+" в разделе 5 группа 6 должно быть tR=1");
                    return false;
                  }
                  if (tlg[12] != '/'){
                    errors.push("Для срока "+term+" в разделе 1 группа 00 должно быть iR='/'");
                    return false;
                  }
                }
                observation.precipitation_time_range_2 = section[4];
                break;
              // case '9':
            }
          } else {
            errors.push(state[name].errorMessage);
            return false;
          }
          section = section.substr(6).trim();
        } else {
          errors.push("Ошибка в разделе 5");
          return false;
        }
      }
    }

    section = '';
    var pos333 = -1;
    if(~tlg.indexOf(" 333 ")){
      pos333 = tlg.indexOf(" 333 ");
      section = tlg.substr(pos333+5, (pos555>0 ? pos555-pos333-5 : tlg.length-pos333-5-1)).trim();
      if(section.length<5){
        errors.push("Ошибка в разделе 3");
        return false;
      }
      // console.log('section3-1:', section);
      while (section.length>=5) {
        if(~['1', '2', '4', '5', '8', '9'].indexOf(section[0])){
          group = section.substr(0,5);
          name = 'group3'+section[0];
          regex = state[name].regex;
          if (regex.test(group) && ((section[5] == ' ') || (section[5] == '=') || (section.length == 5))) {
            switch(section[0]) {
              case '1':
              case '2':
                // sign = section[1] == '0' ? '' : '-';
                val = sign[section[1]]+section.substr(2,2)+'.'+section[4];
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
          section = section.substr(6).trim();
        } else {
          errors.push("Ошибка в разделе 3");
          return false;
        }
      }
    }
    
    var lng = pos333>0 ? pos333-24 : (pos555>0 ? pos555-24 : tlg.length-24);
    section = tlg.substr(24, lng).trim();
    if(section.length<5){
      errors.push("Ошибка в разделе 1");
      return false;
    }
    // var sign = '';
    var val = '';
    var first = '';
    // console.log('section1-1:', section);
    while (section.length>=5) {
      if(~['1', '2', '3', '4', '5', '6', '7', '8'].indexOf(section[0])){
        group = section.substr(0,5);
        name = 'group'+section[0];
        regex = state[name].regex;
        if (regex.test(group) && ((section[5] == ' ') || (section[5] == '=') || (section.length == 5))) {
          switch(section[0]) {
            case '1':
            case '2':
              // sign = section[1] == '0' ? '' : '-';
              val = sign[section[1]]+section.substr(2,2)+'.'+section[4];
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
              if ((term == 6) || (term == 18)){
                if (section[4] != '2'){
                  errors.push("Для срока "+term+" в группе 6 раздела 1 должно быть tR=2");
                  return false;
                }
                if (tlg[12] != '1'){
                  errors.push("Для срока "+term+" в разделе 1 группа 00 должно быть iR=1");
                  return false;
                }
              }
              observation.precipitation_1 = section.substr(1,3);
              observation.precipitation_time_range_1 = section[4];
              break;
            case '7':
              if (tlg[13] != '1'){ // 20180405 согласовано с наблюдателями и Л.А.
                errors.push("При наличии группы 7 раздела 1 долно быть iX=1");
                return false;
              }
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
        section = section.substr(6).trim();
      } else {
        errors.push("Ошибка в разделе 1 => "+section);
        return false;
      }
    }
    return true;
  }
