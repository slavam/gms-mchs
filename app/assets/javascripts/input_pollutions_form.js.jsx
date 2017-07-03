// const React = require("react");
// import Datetime from 'react-datetime';
// require('moment/locale/ru');
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
        <span style={{color: 'red'}}>{this.props.errorMessage}</span>
      </div>
    );
  }
}

class ChemOptionSelect extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      defaultValue: this.props.defaultValue
    };
    this.handleOptionChange = this.handleOptionChange.bind(this);
  }
  handleOptionChange(event) {
    this.props.onUserInput(event.target.value, event.target.name);
  }
  render(){
    return <select name={this.props.name} onChange={this.handleOptionChange} defaultValue = {this.state.defaultValue}>
      {
        this.props.options.map(function(op) {
          return <option key={op.id} value={op.id}>{op.name}</option>;
        })
      }
    </select>;
  }
}
class OnePollution extends React.Component {
  constructor(props) {
    super(props);
    this.handleDeleteClick = this.handleDeleteClick.bind(this);
  }
  handleDeleteClick(e){
    this.props.onClickDeletePollution(this.props.pollution.id);
  }
  render() {
    return (
      <tr key={this.props.material_id}><td>{this.props.pollution.material_name}</td><td>{this.props.pollution.value}</td><td>{this.props.size > 1 ? <input id={this.props.material_id} type="submit" value="Удалить" onClick={this.handleDeleteClick}/> : ''}</td></tr>
    );
  }
}
class PollutionsTable extends React.Component {
  render() {
    var rows = [];
    var size = Object.keys(this.props.concentrations).length;
    if (size == 0)
      return (<div></div>);
    else
      Object.keys(this.props.concentrations).forEach((k) => rows.push(<OnePollution pollution={this.props.concentrations[k]} material_id={k} key={k} size={size} onClickDeletePollution={this.props.onClickDeletePollution} />));
    return (
      <div>
        <h4>Концентрации</h4>
        <table className="table table-hover">
          <thead>
            <tr>
              <th>Вещество</th>
              <th>Значение</th>
              <th>Действие</th>
            </tr>
          </thead>
          <tbody>
            {rows}
          </tbody>
        </table>
      </div>
    );
  }
}
class InputForm extends React.Component{
  constructor(props) {
    super(props);
    var vs = {};
    Object.keys(this.props.concentrations).forEach((k) => vs[k] = this.props.concentrations[k].value);
    this.state = {
      weather: this.props.weather,
      date: this.props.date,
      term: this.props.term,
      postId: this.props.postId,
      concentrations: this.props.concentrations,
      values: vs,
      value: '',
      errors: this.props.errors
    };
    this.dateChange = this.dateChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleOptionSelected = this.handleOptionSelected.bind(this);
    this.handleValueChange = this.handleValueChange.bind(this);
    this.get_weather = this.get_weather.bind(this);
    this.deletePollution = this.deletePollution.bind(this);
  }
  handleOptionSelected(value, senderName){
    if (senderName == 'selectTerm')
      this.state.term = value;
    else 
      this.state.postId = value;
    this.get_weather();
  }
  get_weather(){
    var date = this.state.date; 
    $.ajax({
      type: 'GET',
      url: "weather_update?date="+date+"&term="+this.state.term+"&post_id="+this.state.postId
      }).done(function(data) {
        var weather = {};
        if (data.weather == null) {
          weather.temperature = '';
          weather.wind_speed = '';
          weather.wind_direction = '';
          weather.atmosphere_pressure = '';
        } else
          weather = data.weather;
        var vs = {};
        if (Object.keys(data.concentrations).length > 0)
          Object.keys(data.concentrations).forEach((k) => vs[k] = data.concentrations[k].value);
        this.setState({
          weather: weather,
          concentrations: data.concentrations,
          values: vs,
          errors: data.errors
        });
      }.bind(this))
      .fail(function(res) {
        if(res !== 'undefined')
          this.setState({errors: res.responseJSON.errors});
      });
  }
  handleSubmit(e) {
    var size = Object.keys(this.state.values).length;
    e.preventDefault();
    var that = this;
    var measurement = {};
    if (!this.state.weather.wind_direction) {
      alert('Нет данных о погоде!');
      return;
    }
    if (size == 0) {
      alert('Нет данных о концентрациях!');
      return;
    }
    measurement.date = this.state.date.trim();
    measurement.post_id = this.state.postId;
    measurement.term = this.state.term;
    measurement.wind_direction = this.state.weather.wind_direction;
    measurement.wind_speed = this.state.weather.wind_speed;
    measurement.temperature = this.state.weather.temperature;
    measurement.phenomena = this.state.weather.phenomena;
    measurement.relative_humidity = this.state.weather.relative_humidity;
    measurement.partial_pressure = this.state.weather.partial_pressure;
    measurement.atmosphere_pressure = this.state.weather.atmosphere_pressure;
    this.state.errors = {};
    $.ajax({
      type: 'POST',
      // url: "save_pollutions",
      url: "create_or_update",
      data: {measurement: measurement, values: this.state.values}
      }).done(function(data) {
        that.setState({errors: data.errors, concentrations: data.concentrations});
      }.bind(this))
      .fail(function(res) {
        that.setState({values: {}, value: '', errors: ["Ошибка при сохранении данных. Дублирование записи."]});
        // that.setState({errors: res.errors});
      });
  }
  handleValueChange(e){
    this.state.values[e.target.name] = e.target.value;
    // var name = e.target.name;
    this.setState({value: e.target.value});
    // alert(this.state.values[e.target.name])
  }
  dateChange(e) {
    // var date = e.format("YYYY.MM.DD");
    this.state.date = e.target.value;
    this.get_weather();
    // this.setState({date: e.target.value});
  }
  deletePollution(pollutionId){
    var that = this;
    $.ajax({
      type: 'DELETE',
      url: "/pollution_values/delete_value/"+pollutionId //value_delete?=record_id="+pollutionId
    }).done(function(data){
      var vs = {};
      Object.keys(data.concentrations).forEach((k) => vs[k] = data.concentrations[k].value);
      that.setState({values: vs, concentrations: data.concentrations, errors: data.errors});
    }.bind(this))
    .fail(function(res){});
  }
  render(){
    const terms = [
      { id: '01', name: '01' },
      { id: '07', name: '07' },
      { id: '13', name: '13' },
      { id: '19', name: '19' }
    ];
    var self = this;
    var ths = [];
    var tds = [];
    this.props.materials.map(function(m) {
                ths.push(<th key={m.id}>{m.name}</th>);
                tds.push(<td key={m.id}>
                <input type="number" value={self.state.values[m.id] == null ? '' : self.state.values[m.id]} onChange={self.handleValueChange} name={m.id} min="0.0" step="0.001"/>
                {/*    <InputError visible={self.state[td].errorVisible} errorMessage="Ошибка!" /> */}
                </td>);
              });
    return(
      <div>
        <InputError visible="true" errorMessage={this.state.errors[0]} />
        <form className="pollutionsForm" onSubmit={this.handleSubmit}>
          
          <h3>Создать/изменить запись</h3>
          <table className="table table-hover">
            <thead>
              <tr>
                {ths}
              </tr>
            </thead>
            <tbody>
              <tr>
                {tds}
              </tr>
            </tbody>
          </table>  
          <div>
            Пост: <ChemOptionSelect options={this.props.posts} onUserInput={this.handleOptionSelected} name="selectStation" key="selectStation" defaultValue={this.props.postId}/>
            Срок: <ChemOptionSelect options={terms} onUserInput={this.handleOptionSelected} name = "selectTerm" defaultValue="07"/>
            Дата: <input type="date" name="measurement-date" value={this.state.date} onChange={this.dateChange} required="true" autoComplete="on"/>
            {/* Дата: <Datetime timeFormat={false} dateFormat="YYYY.MM.DD" closeOnSelect={true} onChange={this.dateChange} defaultValue={this.props.date} /> */}
          </div>
          <input type="submit" value="Сохранить" />
        </form>
        <h4>Данные о погоде (дата: {this.state.date}; срок: {this.state.term}; пост: {this.state.postId})</h4>
        <table className="table table-hover">
          <thead>
            <tr>
              <th>Температура воздуха</th>
              <th>Скорость ветра</th>
              <th>Направление ветра</th>
              <th>Атмосферное давление</th>
              <th>Относительная влажность</th>
              <th>Атмосферные явления</th>
              <th>Парциальное давление</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                {this.state.weather.temperature}
              </td>
              <td>
                {this.state.weather.wind_speed}
              </td>
              <td>
                {this.state.weather.wind_direction}
              </td>
              <td>
                {this.state.weather.atmosphere_pressure}
              </td>
              <td>
              </td>
              <td>
              </td>
              <td>
              </td>
            </tr>
          </tbody>
        </table>
        <PollutionsTable concentrations={this.state.concentrations} onClickDeletePollution={this.deletePollution}/>
      </div>
    );
  }
    
}
class InputPollutionsForm extends React.Component{
  constructor(props) {
    super(props);
    var weather = {};
    if (this.props.weather == null) {
      weather.temperature = '';
      weather.wind_speed = '';
      weather.wind_direction = '';
      weather.atmosphere_pressure = '';
    } else
      weather = this.props.weather;
    this.state = {
      weather: weather,
      date: this.props.date,
      term: this.props.term,
      postId: this.props.postId,
      // concentrations: this.props.concentrations,
      errors: []
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
  }

  handleFormSubmit(concentrations) {
    // var that = this;
    // var telegrams = that.state.telegrams;
    // var newTelegrams = [telegram].concat(telegrams);
    // $.ajax({
    //   type: 'POST',
    //   dataType: 'json',
    //   url: "create_synoptic_telegram?t_term="+telegram["Срок"]+"&t_text="+telegram["Телеграмма"]
    //   }).done(function(data) {
    //     // alert(data["Дата"])
    //     newTelegrams[0]["Дата"] = data["Дата"];
    //     that.setState({telegrams: newTelegrams, errors: {}});
    //   }.bind(that))
    //   .fail(function(res) {
    //     that.setState({errors: res.responseJSON.errors});
    //   }.bind(that)); 
  }
  
  render(){
    return(
      <div>
        <InputForm onInputFormSubmit={this.handleFormSubmit} weather = {this.state.weather} errors = {this.state.errors} date={this.state.date} term={this.state.term} materials={this.props.materials} posts={this.props.posts} postId={this.state.postId} concentrations={this.props.concentrations}/>
      </div>
    );
  }
}
// export default InputPollutionsForm;