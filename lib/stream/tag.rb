class Stream::Tag < Stream::Base
  attr_accessor :tag_name, :people_page

  def initialize(user, tag_name, opts={}) 
    super(user, opts)
    self.tag_name = tag_name
    @people_page = opts[:page] || 1
  end

  def tag
    @tag ||= ActsAsTaggableOn::Tag.find_by_name(tag_name)
  end

  def tag_follow_count
    @tag_follow_count ||= tag.try(:followed_count).to_i
  end

  def display_tag_name
    @display_tag_name ||= "##{tag_name}"
  end

  def people
    @people ||= Person.profile_tagged_with(tag_name).paginate(:page => people_page, :per_page => 15)
  end

  def people_count
    @people_count ||= Person.profile_tagged_with(tag_name).count
  end

  def posts
    @posts ||= construct_post_query
  end

  def publisher_prefill_text
    display_tag_name + ' '
  end

  def tag_name=(tag_name)
    @tag_name = tag_name.downcase.gsub('#', '')
  end

  private

  def construct_post_query
    posts = StatusMessage
    if user.present? 
      posts = posts.owned_or_visible_by_user(user)
    else
      posts = posts.all_public
    end
    posts.tagged_with(tag_name).for_a_stream(max_time, 'created_at')
  end
end